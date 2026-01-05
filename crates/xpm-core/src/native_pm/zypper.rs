//! Zypper package manager integration (openSUSE)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

pub struct ZypperPackageManager {
    zypper_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl ZypperPackageManager {
    pub async fn new() -> Self {
        let zypper_path = Executable::new("zypper")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/zypper"));

        let sudo_path = Executable::new("sudo").find();

        Self {
            zypper_path,
            sudo_path,
        }
    }

    async fn run_zypper(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.zypper_path)
            .args(args)
            .output()
            .await
            .context("Failed to run zypper command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("zypper command failed: {}", stderr)
        }
    }

    async fn run_zypper_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.zypper_path);
            cmd
        } else {
            Command::new(&self.zypper_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run zypper command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("zypper command failed: {}", stderr)
        }
    }

    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            if line.trim().is_empty()
                || line.starts_with("Loading")
                || line.starts_with("S ")
                || line.starts_with("--")
            {
                continue;
            }

            let parts: Vec<&str> = line.split('|').map(|s| s.trim()).collect();
            if parts.len() >= 3 {
                let status = parts.first().unwrap_or(&"");
                let name = parts.get(1).unwrap_or(&"").to_string();
                let version = parts.get(3).map(|s| s.to_string());

                if name.is_empty() {
                    continue;
                }

                packages.push(NativePackage {
                    name,
                    version,
                    description: parts.get(2).map(|s| s.to_string()),
                    arch: parts.get(4).map(|s| s.to_string()),
                    repo: parts.get(5).map(|s| s.to_string()),
                    popularity: None,
                    installed: status.contains('i'),
                });
            }
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for ZypperPackageManager {
    fn name(&self) -> &str {
        "zypper"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_zypper(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_zypper_sudo(&["install", "-y", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_zypper_sudo(&["remove", "-y", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new("rpm").args(["-q", name]).output().await?;

        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_zypper(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" => pkg.version = Some(value.to_string()),
                            "Summary" | "Description" => pkg.description = Some(value.to_string()),
                            "Arch" => pkg.arch = Some(value.to_string()),
                            _ => {}
                        }
                    }
                }

                pkg.installed = self.is_installed(name).await.unwrap_or(false);
                Ok(Some(pkg))
            }
            Err(_) => Ok(None),
        }
    }

    async fn update_db(&self) -> Result<()> {
        self.run_zypper_sudo(&["refresh"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = ZypperPackageManager {
            zypper_path: PathBuf::from("/usr/bin/zypper"),
            sudo_path: None,
        };

        let output = "S  | Name       | Summary          | Type   \n\
                      ---+------------+------------------+--------\n\
                      i  | vim        | Vi IMproved      | package\n\
                         | vim-data   | Vim data files   | package";

        let packages = pm.parse_search_output(output);

        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "vim");
        assert!(packages[0].installed);
        assert_eq!(packages[1].name, "vim-data");
        assert!(!packages[1].installed);
    }

    #[test]
    fn test_name() {
        let pm = ZypperPackageManager {
            zypper_path: PathBuf::from("/usr/bin/zypper"),
            sudo_path: None,
        };
        assert_eq!(pm.name(), "zypper");
    }
}
