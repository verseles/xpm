//! swupd package manager integration (Clear Linux)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

pub struct SwupdPackageManager {
    swupd_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl SwupdPackageManager {
    pub async fn new() -> Self {
        let swupd_path = Executable::new("swupd")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/swupd"));

        let sudo_path = Executable::new("sudo").find();

        Self { swupd_path, sudo_path }
    }

    async fn run_swupd(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.swupd_path)
            .args(args)
            .output()
            .await
            .context("Failed to run swupd command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("swupd command failed: {}", stderr)
        }
    }

    async fn run_swupd_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.swupd_path);
            cmd
        } else {
            Command::new(&self.swupd_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run swupd command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("swupd command failed: {}", stderr)
        }
    }

    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let trimmed = line.trim();
            if trimmed.is_empty() || trimmed.starts_with("Searching") || trimmed.starts_with("Bundle") {
                continue;
            }

            if let Some(name) = trimmed.split_whitespace().next() {
                packages.push(NativePackage::new(name));
            }
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for SwupdPackageManager {
    fn name(&self) -> &str {
        "swupd"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_swupd(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_swupd_sudo(&["bundle-add", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_swupd_sudo(&["bundle-remove", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = self.run_swupd(&["bundle-list"]).await?;
        Ok(output.lines().any(|line| line.trim() == name))
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_swupd(&["bundle-info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);

                for line in output.lines() {
                    if line.contains("Description:") {
                        pkg.description = line.split(':').nth(1).map(|s| s.trim().to_string());
                    }
                }

                pkg.installed = self.is_installed(name).await.unwrap_or(false);
                Ok(Some(pkg))
            }
            Err(_) => Ok(None),
        }
    }

    async fn update_db(&self) -> Result<()> {
        self.run_swupd_sudo(&["update"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = SwupdPackageManager {
            swupd_path: PathBuf::from("/usr/bin/swupd"),
            sudo_path: None,
        };

        let output = "Searching for 'vim'...\n\
                      Bundle vim-go\n\
                      vim\n\
                      neovim";

        let packages = pm.parse_search_output(output);

        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "vim");
        assert_eq!(packages[1].name, "neovim");
    }

    #[test]
    fn test_name() {
        let pm = SwupdPackageManager {
            swupd_path: PathBuf::from("/usr/bin/swupd"),
            sudo_path: None,
        };
        assert_eq!(pm.name(), "swupd");
    }
}
