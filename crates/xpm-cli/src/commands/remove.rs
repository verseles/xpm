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

            // Validate removal: validation should FAIL after successful removal
            if script.has_function("validate") {
                let validate_script = format!(r#"source "{}" && validate"#, script_path);
                match run_script(&validate_script, "validation").await {
                    Ok(_) => {
                        // Validation passed = package still exists = warning
                        Logger::warning("Package may not have been fully removed");
                    }
                    Err(_) => {
                        // Validation failed = package was removed = success
                    }
                }
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
    use std::sync::Arc;

    let spinner = Arc::new(ProgressBar::new_spinner());
    spinner.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.red} {msg}")
            .unwrap(),
    );
    spinner.set_message(format!("Removing {}...", name));
    spinner.enable_steady_tick(Duration::from_millis(100));

    let mut child = Command::new("bash")
        .arg("-c")
        .arg(script)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    let stdout = child.stdout.take();
    let stderr = child.stderr.take();

    // Spawn task to read stdout
    let spinner_stdout = Arc::clone(&spinner);
    let stdout_task = tokio::spawn(async move {
        if let Some(stdout) = stdout {
            let reader = BufReader::new(stdout);
            let mut lines = reader.lines();

            while let Ok(Some(line)) = lines.next_line().await {
                spinner_stdout.set_message(line);
            }
        }
    });

    // Spawn task to read stderr
    let spinner_stderr = Arc::clone(&spinner);
    let stderr_task = tokio::spawn(async move {
        if let Some(stderr) = stderr {
            let reader = BufReader::new(stderr);
            let mut lines = reader.lines();

            while let Ok(Some(line)) = lines.next_line().await {
                // Display stderr in yellow to differentiate from stdout
                spinner_stderr.set_message(format!("{}", line.yellow()));
            }
        }
    });

    // Wait for both streams to complete
    let _ = tokio::try_join!(stdout_task, stderr_task)?;

    let status = child.wait().await?;
    spinner.finish_and_clear();

    if !status.success() {
        anyhow::bail!("Remove script failed with exit code: {:?}", status.code());
    }

    Ok(())
}
