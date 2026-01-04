//! Repository management command implementation

use crate::RepoAction;
use anyhow::Result;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use std::time::Duration;
use xpm_core::{
    repo::Repositories,
    utils::logger::Logger,
};

/// Run the repo command
pub async fn run(action: RepoAction) -> Result<()> {
    match action {
        RepoAction::Add { url } => add(&url).await,
        RepoAction::Remove { url } => remove(&url).await,
        RepoAction::List => list().await,
    }
}

async fn add(url: &str) -> Result<()> {
    Logger::info(&format!("Adding repository: {}...", url.cyan()));

    let spinner = ProgressBar::new_spinner();
    spinner.set_style(
        ProgressStyle::default_spinner()
            .template("{spinner:.cyan} {msg}")
            .unwrap()
    );
    spinner.set_message("Cloning repository...");
    spinner.enable_steady_tick(Duration::from_millis(100));

    let repo = Repositories::add_repo(url).await?;

    spinner.finish_and_clear();

    let repo_name = Repositories::repo_name(&repo.url);
    Logger::success(&format!("Added repository: {}", repo_name.green()));

    // Index the repository
    Logger::info("Indexing packages...");
    let indexed = Repositories::index().await?;
    Logger::success(&format!("Indexed {} packages", indexed.to_string().green()));

    Ok(())
}

async fn remove(url: &str) -> Result<()> {
    Logger::info(&format!("Removing repository: {}...", url.red()));

    let removed = Repositories::remove_repo(url).await?;

    if removed {
        Logger::success("Repository removed");
    } else {
        Logger::warning("Repository not found");
    }

    Ok(())
}

async fn list() -> Result<()> {
    let repos = Repositories::all_repos()?;

    if repos.is_empty() {
        Logger::info("No repositories configured");
        Logger::info(&format!(
            "Add the default repository with: {} repo add https://github.com/verseles/xpm-popular.git",
            "xpm".cyan()
        ));
        return Ok(());
    }

    println!("{}", "━━━ Configured Repositories ━━━".cyan().bold());
    println!();

    for repo in repos {
        let name = Repositories::repo_name(&repo.url);
        let last_sync = repo.last_sync
            .map(|t| t.format("%Y-%m-%d %H:%M:%S").to_string())
            .unwrap_or_else(|| "never".to_string());

        println!("  {} {}", "📦".to_string(), name.green().bold());
        println!("     URL: {}", repo.url.dimmed());
        println!("     Last sync: {}", last_sync.dimmed());
        println!();
    }

    Ok(())
}
