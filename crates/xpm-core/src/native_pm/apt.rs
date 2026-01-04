//! APT package manager integration (Debian/Ubuntu)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

/// APT package manager
pub struct AptPackageManager {
    apt_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl AptPackageManager {
    /// Create a new APT package manager
    pub async fn new() -> Self {
        let apt_path = Executable::new("apt")
            .find()
            .or_else(|| Executable::new("apt-get").find())
            .unwrap_or_else(|| PathBuf::from("/usr/bin/apt"));

        let sudo_path = Executable::new("sudo").find();

        Self {
            apt_path,
            sudo_path,
        }
    }

    /// Run apt command
    async fn run_apt(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.apt_path)
            .args(args)
            .output()
            .await
            .context("Failed to run apt command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("apt command failed: {}", stderr)
        }
    }

    /// Run apt command with sudo
    async fn run_apt_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.apt_path);
            cmd
        } else {
            Command::new(&self.apt_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run apt command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("apt command failed: {}", stderr)
        }
    }

    /// Parse apt search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            // apt search format: package/release version arch [installed]
            // Or: package - description
            if line.trim().is_empty()
                || line.starts_with("Sorting")
                || line.starts_with("Full Text")
            {
                continue;
            }

            // Try to parse package line
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.is_empty() {
                continue;
            }

            let name_part = parts[0];
            let name = name_part.split('/').next().unwrap_or(name_part);

            // Skip if it looks like a description line (starts with whitespace)
            if line.starts_with(' ') || line.starts_with('\t') {
                continue;
            }

            let version = parts.get(1).map(|s| s.to_string());
            let installed = line.contains("[installed");

            packages.push(NativePackage {
                name: name.to_string(),
                version,
                description: None,
                arch: parts.get(2).map(|s| s.to_string()),
                repo: None,
                popularity: None,
                installed,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for AptPackageManager {
    fn name(&self) -> &str {
        "apt"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_apt(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_apt_sudo(&["install", "-y", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_apt_sudo(&["remove", "-y", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new("dpkg").args(["-s", name]).output().await?;

        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_apt(&["show", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" => pkg.version = Some(value.to_string()),
                            "Description" => pkg.description = Some(value.to_string()),
                            "Architecture" => pkg.arch = Some(value.to_string()),
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
        self.run_apt_sudo(&["update"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = AptPackageManager {
            apt_path: PathBuf::from("/usr/bin/apt"),
            sudo_path: None,
        };

        let output = r#"Sorting... Done
Full Text Search... Done
vim/stable 2:8.2.2434-3 amd64
  Vi IMproved - enhanced vi editor

nano/stable,now 5.4-2 amd64 [installed]
  small, friendly text editor inspired by Pico
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "vim");
        assert!(!packages[0].installed);
        assert_eq!(packages[1].name, "nano");
        assert!(packages[1].installed);
    }
}
