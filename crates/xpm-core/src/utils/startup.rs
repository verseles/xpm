//! Startup checks for XPM
//!
//! Handles auto-update checking and auto-refresh of repositories.

use anyhow::Result;

use owo_colors::OwoColorize;
use reqwest::Client;
use serde::Deserialize;

use crate::db::Database;
use crate::repo::Repositories;
use crate::utils::version::is_newer;
use crate::utils::Logger;
use crate::VERSION;

const GITHUB_RELEASES_API: &str = "https://api.github.com/repos/verseles/xpm/releases/latest";
const UPDATE_CHECK_DAYS: i64 = 4;
const REPO_REFRESH_DAYS: i64 = 7;
const SETTING_NEEDS_UPDATE: &str = "needs_update";
const SETTING_NEEDS_REFRESH: &str = "needs_refresh";

#[derive(Debug, Deserialize)]
struct GitHubRelease {
    tag_name: String,
}

pub struct StartupChecks;

impl StartupChecks {
    pub async fn run_all(quiet: bool) -> Result<()> {
        let db = Database::instance()?;

        Self::auto_refresh_repos(db, quiet).await?;
        Self::check_for_updates(db, quiet).await?;
        db.delete_expired_settings()?;

        Ok(())
    }

    async fn auto_refresh_repos(db: &Database, quiet: bool) -> Result<()> {
        let needs_refresh: bool = db.get_setting_or(SETTING_NEEDS_REFRESH, true)?;

        if needs_refresh {
            if !quiet {
                Logger::info("Auto-refreshing package database...");
            }

            match Repositories::index().await {
                Ok(count) => {
                    if !quiet {
                        Logger::success(&format!("Indexed {} packages", count));
                    }
                    db.set_setting_with_expiry(
                        SETTING_NEEDS_REFRESH,
                        &false,
                        Some(chrono::TimeDelta::days(REPO_REFRESH_DAYS)),
                    )?;
                }
                Err(e) => {
                    if !quiet {
                        Logger::warning(&format!("Failed to refresh repositories: {}", e));
                    }
                }
            }
        }

        Ok(())
    }

    async fn check_for_updates(db: &Database, quiet: bool) -> Result<()> {
        let needs_update: bool = db.get_setting_or(SETTING_NEEDS_UPDATE, true)?;

        if !needs_update {
            return Ok(());
        }

        db.set_setting_with_expiry(
            SETTING_NEEDS_UPDATE,
            &false,
            Some(chrono::TimeDelta::days(UPDATE_CHECK_DAYS)),
        )?;

        let latest_version = match Self::fetch_latest_version().await {
            Ok(v) => v,
            Err(_) => return Ok(()),
        };

        if is_newer(&latest_version, VERSION) && !quiet {
            println!(
                "\n{}",
                format!(
                    "  ⬆ A new version of xpm is available: {} → {}",
                    VERSION.yellow(),
                    latest_version.green()
                )
                .bold()
            );
            println!(
                "    Run {} or visit {}\n",
                "xpm upgrade".cyan(),
                "https://github.com/verseles/xpm/releases".blue()
            );
        }

        Ok(())
    }

    async fn fetch_latest_version() -> Result<String> {
        let client = Client::builder()
            .user_agent(format!("xpm/{}", VERSION))
            .timeout(std::time::Duration::from_secs(5))
            .build()?;

        let response: GitHubRelease = client.get(GITHUB_RELEASES_API).send().await?.json().await?;

        let version = response.tag_name.trim_start_matches('v').to_string();
        Ok(version)
    }
}
