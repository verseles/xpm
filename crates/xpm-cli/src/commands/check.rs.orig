//! System check command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::{
    db::Database,
    native_pm::{detect_native_pm, NativePackageManager},
    os::{dirs::XpmDirs, executable::Executable, get_architecture, get_os_info},
    repo::Repositories,
    utils::logger::Logger,
    VERSION,
};

/// Run the check command
pub async fn run() -> Result<()> {
    println!("{}", "━━━ XPM System Check ━━━".cyan().bold());
    println!();

    // Version info
    println!("{}", "Version".bold());
    println!("  XPM version: {}", VERSION.green());
    println!();

    // OS info
    let os_info = get_os_info();
    let arch = get_architecture();

    println!("{}", "System".bold());
    println!(
        "  OS: {} ({})",
        format!("{:?}", os_info.os_type).green(),
        os_info.pretty_name.as_str()
    );
    println!("  Architecture: {}", format!("{:?}", arch).green());
    println!();

    // Directories
    println!("{}", "Directories".bold());
    match XpmDirs::data_dir() {
        Ok(dir) => {
            let exists = dir.exists();
            let status = if exists {
                format!("{}", "✓".green())
            } else {
                format!("{}", "✗".red())
            };
            println!("  Data: {} {}", dir.display(), status);
        }
        Err(e) => println!("  Data: {} {}", "Error".red(), e),
    }
    match XpmDirs::cache_dir() {
        Ok(dir) => {
            let exists = dir.exists();
            let status = if exists {
                format!("{}", "✓".green())
            } else {
                format!("{}", "✗".red())
            };
            println!("  Cache: {} {}", dir.display(), status);
        }
        Err(e) => println!("  Cache: {} {}", "Error".red(), e),
    }
    match XpmDirs::bin_dir() {
        Ok(dir) => {
            let exists = dir.exists();
            let in_path = std::env::var("PATH")
                .map(|p| p.contains(&dir.to_string_lossy().to_string()))
                .unwrap_or(false);
            let status = if exists && in_path {
                format!("{}", "✓".green())
            } else if exists {
                format!("{}", "⚠".yellow())
            } else {
                format!("{}", "✗".red())
            };
            let path_note = if !in_path && exists {
                format!("{}", "(not in PATH)".yellow())
            } else {
                String::new()
            };
            println!("  Bin: {} {} {}", dir.display(), status, path_note);
        }
        Err(e) => println!("  Bin: {} {}", "Error".red(), e),
    }
    println!();

    // Native package manager
    println!("{}", "Package Manager".bold());
    if let Some(pm) = detect_native_pm().await {
        println!("  Detected: {}", pm.name().green());
    } else {
        println!("  Detected: {}", "None".yellow());
    }
    println!();

    // Required tools
    println!("{}", "Required Tools".bold());
    let tools = ["git", "bash", "curl", "sudo"];
    for tool in tools {
        let found = Executable::new(tool).find().is_some();
        let status = if found {
            format!("{}", "✓".green())
        } else {
            format!("{}", "✗".red())
        };
        println!("  {}: {}", tool, status);
    }
    println!();

    // Database
    println!("{}", "Database".bold());
    match Database::instance() {
        Ok(db) => {
            let packages = db.get_all_packages().unwrap_or_default();
            let installed = db.get_installed_packages().unwrap_or_default();
            println!("  Status: {}", "OK".green());
            println!("  Total packages: {}", packages.len().to_string().cyan());
            println!("  Installed: {}", installed.len().to_string().green());
        }
        Err(e) => println!("  Status: {} ({})", "Error".red(), e),
    }
    println!();

    // Repositories
    println!("{}", "Repositories".bold());
    match Repositories::all_repos() {
        Ok(repos) => {
            if repos.is_empty() {
                println!("  Status: {}", "No repositories configured".yellow());
                println!(
                    "  Tip: Run {} to add the default repository",
                    "xpm refresh".cyan()
                );
            } else {
                println!("  Configured: {}", repos.len().to_string().green());
                for repo in &repos {
                    let name = Repositories::repo_name(&repo.url);
                    println!("    - {}", name.cyan());
                }
            }
        }
        Err(e) => println!("  Status: {} ({})", "Error".red(), e),
    }
    println!();

    Logger::success("System check complete");
    Ok(())
}
