//! Refresh command implementation

use anyhow::Result;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use std::time::Duration;
use xpm_core::{
    repo::Repositories,
    utils::logger::Logger,
};

/// Run the refresh command
pub async fn run() -> Result<()> {
    Logger::info("Refreshing package database...");

    let spinner = ProgressBar::new_spinner();
    spinner.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.cyan} {msg}")
            .unwrap()
    );
    spinner.set_message("Pulling repositories...");
    spinner.enable_steady_tick(Duration::from_millis(100));

    // Pull all repos and index packages
    let indexed = Repositories::index().await?;

    spinner.finish_and_clear();

    Logger::success(&format!(
        "Indexed {} packages from {} repositories",
        indexed.to_string().green(),
        Repositories::all_repos()?.len().to_string().cyan()
    ));

    Ok(())
}
