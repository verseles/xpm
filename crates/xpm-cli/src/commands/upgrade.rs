use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::{db::Database, utils::logger::Logger};

use crate::commands::install;

pub async fn run() -> Result<()> {
    let db = Database::instance()?;

    let installed = db.get_installed_packages()?;

    if installed.is_empty() {
        Logger::info("No packages installed via XPM");
        return Ok(());
    }

    Logger::info(&format!(
        "Checking {} installed packages...",
        installed.len()
    ));

    let mut upgradable = Vec::new();

    for pkg in &installed {
        let installed_version = match &pkg.installed {
            Some(v) => v,
            None => continue,
        };

        let latest_version = match &pkg.version {
            Some(v) => v,
            None => continue,
        };

        if installed_version != latest_version {
            upgradable.push((
                pkg.clone(),
                installed_version.clone(),
                latest_version.clone(),
            ));
        }
    }

    if upgradable.is_empty() {
        Logger::success("All packages are up to date");
        return Ok(());
    }

    Logger::info(&format!(
        "{} packages can be upgraded:",
        upgradable.len().to_string().yellow()
    ));

    for (pkg, old_ver, new_ver) in &upgradable {
        println!(
            "  {} {} -> {}",
            pkg.name.cyan(),
            old_ver.red(),
            new_ver.green()
        );
    }

    println!();
    Logger::info("Upgrading packages...");

    for (pkg, _, _) in &upgradable {
        let method = pkg.method.as_deref().unwrap_or("auto");
        let channel = pkg.channel.as_deref();

        if let Err(e) = install::run(&pkg.name, method, false, channel, &[], "auto").await {
            Logger::error(&format!("Failed to upgrade {}: {}", pkg.name, e));
        }
    }

    Logger::success("Upgrade complete");
    Ok(())
}
