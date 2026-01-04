//! Homebrew package manager integration (macOS/Linux)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

pub struct BrewPackageManager {
    brew_path: PathBuf,
}

impl BrewPackageManager {
    pub async fn new() -> Self {
        let brew_path = Executable::new("brew")
            .find()
            .unwrap_or_else(|| PathBuf::from("/opt/homebrew/bin/brew"));

        Self { brew_path }
    }

    async fn run_brew(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.brew_path)
            .args(args)
            .env("HOMEBREW_NO_AUTO_UPDATE", "1")
            .output()
            .await
            .context("Failed to run brew command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("brew command failed: {}", stderr)
        }
    }

    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        output
            .lines()
            .filter(|line| !line.trim().is_empty() && !line.starts_with("==>"))
            .map(|line| NativePackage::new(line.trim()))
            .collect()
    }
}

#[async_trait]
impl NativePackageManager for BrewPackageManager {
    fn name(&self) -> &str {
        "brew"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_brew(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_brew(&["install", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_brew(&["uninstall", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new(&self.brew_path)
            .args(["list", name])
            .output()
            .await?;

        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_brew(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                let lines: Vec<&str> = output.lines().collect();

                if let Some(first_line) = lines.first() {
                    let parts: Vec<&str> = first_line.split_whitespace().collect();
                    if parts.len() >= 2 {
                        pkg.version = Some(parts[1].to_string());
                    }
                }

                if let Some(desc_line) = lines.get(1) {
                    pkg.description = Some(desc_line.to_string());
                }

                pkg.installed = self.is_installed(name).await.unwrap_or(false);
                Ok(Some(pkg))
            }
            Err(_) => Ok(None),
        }
    }

    async fn update_db(&self) -> Result<()> {
        self.run_brew(&["update"]).await?;
        Ok(())
    }
}
