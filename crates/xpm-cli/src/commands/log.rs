//! Log command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::{db::Database, utils::logger::Logger};

/// Run the log command
pub async fn run(count: usize) -> Result<()> {
    let db = Database::instance()?;

    // Get installed packages
    let installed = db.get_installed_packages()?;

    if installed.is_empty() {
        Logger::info("No packages installed via XPM");
        return Ok(());
    }

    println!("{}", "━━━ Installed Packages ━━━".cyan().bold());
    println!();

    let display_count = count.min(installed.len());

    for pkg in installed.iter().take(display_count) {
        let name = format!("{}", pkg.name.green().bold());
        let version = format!("{}", pkg.installed.as_deref().unwrap_or("unknown").dimmed());
        let method = pkg.method.as_deref().unwrap_or("unknown");
        let channel = pkg.channel.as_deref().unwrap_or("stable");

        println!("  {} {}", name, version);
        println!(
            "    Method: {}  Channel: {}",
            method.cyan(),
            channel.yellow()
        );
        println!();
    }

    if installed.len() > display_count {
        println!(
            "  ... and {} more. Use {} to see all.",
            (installed.len() - display_count).to_string().yellow(),
            format!("xpm log -c {}", installed.len()).cyan()
        );
    }

    println!();
    println!(
        "Total: {} packages installed",
        installed.len().to_string().green().bold()
    );

    Ok(())
}
