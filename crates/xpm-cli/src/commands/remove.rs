//! Remove command implementation

use anyhow::Result;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use std::process::Stdio;
use std::time::Duration;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use xpm_core::{
    db::Database,
    native_pm::{detect_native_pm, NativePackageManager},
    os::{get_os_info, OsType},
    script::BashScript,
    utils::logger::Logger,
};

/// Run the remove command
pub async fn run(package: &str) -> Result<()> {
    Logger::info(&format!("Removing {}...", package.red().bold()));

    let db = Database::instance()?;

    // Try to find package in XPM database
    if let Some(pkg) = db.find_package_by_name(package)? {
        if !pkg.is_installed() {
            Logger::warning(&format!("{} is not installed via XPM", package));

            // Try native PM
            return try_native_remove(package).await;
        }

        // Get removal method
        let method = pkg.method.as_deref().unwrap_or("any");

        if let Some(script_path) = &pkg.script {
            let script = BashScript::new(script_path);

            if script.has_function(&format!("remove_{}", method)) {
                let remove_script = build_remove_script(script_path, method)?;
                run_script(&remove_script, &pkg.name).await?;
            } else if script.has_function("remove_any") {
                let remove_script = build_remove_script(script_path, "any")?;
                run_script(&remove_script, &pkg.name).await?;
            } else {
                Logger::warning("No removal script found, trying native package manager...");
                try_native_remove(package).await?;
            }
        }

        // Update database
        let mut updated_pkg = pkg.clone();
        updated_pkg.installed = None;
        updated_pkg.method = None;
        updated_pkg.channel = None;
        db.upsert_package(updated_pkg)?;

        Logger::success(&format!("{} removed successfully", package.green()));
        return Ok(());
    }

    // Try native package manager
    try_native_remove(package).await
}

async fn try_native_remove(package: &str) -> Result<()> {
    if let Some(pm) = detect_native_pm().await {
        if pm.is_installed(package).await? {
            Logger::info(&format!("Removing via {}...", pm.name().cyan()));
            pm.remove(package).await?;
            Logger::success(&format!("{} removed successfully", package.green()));
            return Ok(());
        }
    }

    anyhow::bail!("Package '{}' is not installed", package)
}

fn build_remove_script(script_path: &str, method: &str) -> Result<String> {
    let os_info = get_os_info();

    let sudo_cmd = if os_info.os_type == OsType::Android {
        "".to_string()
    } else {
        std::env::var("XPM_SUDO").unwrap_or_else(|_| "sudo".to_string())
    };

    let script = format!(
        r#"#!/bin/bash
set -e

export XPM_SUDO="{sudo_cmd}"

# Source the package script
source "{script_path}"

# Run removal
remove_{method} "$XPM_SUDO"
"#,
        sudo_cmd = sudo_cmd,
        script_path = script_path,
        method = method
    );

    Ok(script)
}

async fn run_script(script: &str, name: &str) -> Result<()> {
    let spinner = ProgressBar::new_spinner();
    spinner.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.red} {msg}")
            .unwrap()
    );
    spinner.set_message(format!("Removing {}...", name));
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
        anyhow::bail!("Remove script failed with exit code: {:?}", status.code());
    }

    Ok(())
}
