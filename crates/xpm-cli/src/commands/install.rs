//! Install command implementation

use anyhow::Result;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use std::process::Stdio;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use xpm_core::{
    db::{Database, Package},
    native_pm::{detect_native_pm, NativePackageManager},
    os::{get_os_info, OsType},
    script::BashScript,
    utils::logger::Logger,
};

/// Run the install command
pub async fn run(package: &str, method: &str, channel: Option<&str>) -> Result<()> {
    Logger::info(&format!("Installing {}...", package.green().bold()));

    let db = Database::instance()?;

    // Try to find package in XPM database
    if let Some(pkg) = db.find_package_by_name(package)? {
        if pkg.is_installed() {
            Logger::warning(&format!("{} is already installed", package));
            return Ok(());
        }

        return install_xpm_package(&pkg, method, channel).await;
    }

    // Try native package manager
    if let Some(pm) = detect_native_pm().await {
        Logger::info(&format!("Package not in XPM, trying {}...", pm.name().cyan()));

        if let Ok(Some(_)) = pm.get(package).await {
            Logger::info(&format!("Installing via {}...", pm.name().cyan()));
            pm.install(package).await?;
            Logger::success(&format!("{} installed successfully", package.green()));
            return Ok(());
        }
    }

    anyhow::bail!("Package '{}' not found", package)
}

async fn install_xpm_package(pkg: &Package, method: &str, channel: Option<&str>) -> Result<()> {
    let script_path = pkg.script.as_ref()
        .ok_or_else(|| anyhow::anyhow!("Package has no installation script"))?;

    let script = BashScript::new(script_path);
    if !script.exists() {
        anyhow::bail!("Installation script not found: {}", script_path);
    }

    // Determine installation method
    let install_method = determine_method(method, pkg, &script)?;
    Logger::info(&format!("Using method: {}", install_method.cyan()));

    // Check for validate function
    let has_validate = script.has_function("validate");

    // Build installation script
    let install_script = build_install_script(script_path, &install_method, channel)?;

    // Run installation
    run_script(&install_script, &pkg.name).await?;

    // Validate installation if possible
    if has_validate {
        let validate_script = format!(
            r#"source "{}" && validate"#,
            script_path
        );

        match run_script(&validate_script, "validation").await {
            Ok(_) => Logger::success("Validation passed"),
            Err(_) => Logger::warning("Validation failed - package may not be installed correctly"),
        }
    }

    // Update database
    let db = Database::instance()?;
    let mut updated_pkg = pkg.clone();
    updated_pkg.installed = Some(pkg.version.clone().unwrap_or_else(|| "unknown".to_string()));
    updated_pkg.method = Some(install_method);
    updated_pkg.channel = channel.map(String::from);
    db.upsert_package(updated_pkg)?;

    Logger::success(&format!("{} installed successfully", pkg.name.green()));
    Ok(())
}

fn determine_method(requested: &str, pkg: &Package, script: &BashScript) -> Result<String> {
    if requested != "auto" {
        // Verify requested method is available
        if script.has_function(&format!("install_{}", requested)) {
            return Ok(requested.to_string());
        }
        anyhow::bail!("Method '{}' not available for this package", requested);
    }

    // Auto detection
    let os_info = get_os_info();

    // Try defaults first
    for default in &pkg.defaults {
        if script.has_function(&format!("install_{}", default)) {
            return Ok(default.clone());
        }
    }

    // Try OS-specific method based on distro detection
    let os_method = if os_info.is_arch_based() {
        "pacman"
    } else if os_info.is_debian_based() {
        "apt"
    } else if os_info.is_fedora_based() {
        "dnf"
    } else if os_info.is_suse_based() {
        "zypper"
    } else if os_info.is_clear_linux() {
        "swupd"
    } else if os_info.is_termux() {
        "termux"
    } else {
        match os_info.os_type {
            OsType::MacOS => "brew",
            OsType::Android => "termux",
            _ => "any",
        }
    };

    if script.has_function(&format!("install_{}", os_method)) {
        return Ok(os_method.to_string());
    }

    // Fallback to 'any'
    if script.has_function("install_any") {
        return Ok("any".to_string());
    }

    anyhow::bail!("No suitable installation method found")
}

fn build_install_script(script_path: &str, method: &str, channel: Option<&str>) -> Result<String> {
    let os_info = get_os_info();

    let sudo_cmd = if os_info.os_type == OsType::Android {
        "".to_string()
    } else {
        std::env::var("XPM_SUDO").unwrap_or_else(|_| "sudo".to_string())
    };

    let channel = channel.unwrap_or("stable");

    let script = format!(
        r#"#!/bin/bash
set -e

export XPM_SUDO="{sudo_cmd}"
export XPM_CHANNEL="{channel}"

# Source the package script
source "{script_path}"

# Run installation
install_{method} "$XPM_SUDO"
"#,
        sudo_cmd = sudo_cmd,
        channel = channel,
        script_path = script_path,
        method = method
    );

    Ok(script)
}

async fn run_script(script: &str, name: &str) -> Result<()> {
    let spinner = ProgressBar::new_spinner();
    spinner.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.cyan} {msg}")
            .unwrap()
    );
    spinner.set_message(format!("Running {}...", name));
    spinner.enable_steady_tick(Duration::from_millis(100));

    let mut child = Command::new("bash")
        .arg("-c")
        .arg(script)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    // Stream stdout
    if let Some(stdout) = child.stdout.take() {
        let reader = BufReader::new(stdout);
        let mut lines = reader.lines();

        while let Ok(Some(line)) = lines.next_line().await {
            spinner.set_message(line);
        }
    }

    let status = child.wait().await?;
    spinner.finish_and_clear();

    if !status.success() {
        anyhow::bail!("Script failed with exit code: {:?}", status.code());
    }

    Ok(())
}
