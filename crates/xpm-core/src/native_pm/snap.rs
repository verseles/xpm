//! Snap package manager integration

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

/// Snap package manager
pub struct SnapPackageManager {
    snap_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl SnapPackageManager {
    /// Create a new Snap package manager
    pub async fn new() -> Self {
        let snap_path = Executable::new("snap")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/snap"));

        let sudo_path = Executable::new("sudo").find();

        Self {
            snap_path,
            sudo_path,
        }
    }

    /// Run snap command
    async fn run_snap(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.snap_path)
            .args(args)
            .output()
            .await
            .context("Failed to run snap command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("snap command failed: {}", stderr)
        }
    }

    /// Run snap command with sudo
    async fn run_snap_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.snap_path);
            cmd
        } else {
            Command::new(&self.snap_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run snap command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("snap command failed: {}", stderr)
        }
    }

    /// Parse snap find output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines().skip(1) {
            // Skip header line
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 4 {
                continue;
            }

            // Format: Name  Version  Publisher  Notes  Summary
            let name = parts[0].to_string();
            let version = Some(parts[1].to_string());
            let description = if parts.len() > 4 {
                Some(parts[4..].join(" "))
            } else {
                None
            };

            packages.push(NativePackage {
                name,
                version,
                description,
                arch: None,
                repo: Some("snap".to_string()),
                popularity: None,
                installed: false,
            });
        }

        packages
    }

    /// Parse snap list output for installed packages
    fn parse_list_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines().skip(1) {
            // Skip header line
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 2 {
                continue;
            }

            // Format: Name  Version  Rev  Tracking  Publisher  Notes
            packages.push(NativePackage {
                name: parts[0].to_string(),
                version: Some(parts[1].to_string()),
                description: None,
                arch: None,
                repo: Some("snap".to_string()),
                popularity: None,
                installed: true,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for SnapPackageManager {
    fn name(&self) -> &str {
        "snap"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_snap(&["find", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_snap_sudo(&["install", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_snap_sudo(&["remove", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = self.run_snap(&["list", name]).await;
        Ok(output.is_ok())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_snap(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                pkg.repo = Some("snap".to_string());

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "version" => pkg.version = Some(value.to_string()),
                            "summary" => pkg.description = Some(value.to_string()),
                            "installed" => pkg.installed = !value.is_empty() && value != "-",
                            _ => {}
                        }
                    }
                }

                if !pkg.installed {
                    pkg.installed = self.is_installed(name).await.unwrap_or(false);
                }

                Ok(Some(pkg))
            }
            Err(_) => Ok(None),
        }
    }

    async fn update_db(&self) -> Result<()> {
        self.run_snap_sudo(&["refresh", "--list"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = SnapPackageManager {
            snap_path: PathBuf::from("/usr/bin/snap"),
            sudo_path: None,
        };

        let output = r#"Name            Version          Publisher          Notes    Summary
micro           2.0.11           benweiss           -        Modern and intuitive terminal-based text editor
code            1.84.0           vscode✓            classic  Code editing. Redefined.
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "micro");
        assert_eq!(packages[0].version, Some("2.0.11".to_string()));
        assert_eq!(packages[1].name, "code");
    }

    #[test]
    fn test_parse_list_output() {
        let pm = SnapPackageManager {
            snap_path: PathBuf::from("/usr/bin/snap"),
            sudo_path: None,
        };

        let output = r#"Name      Version    Rev    Tracking       Publisher   Notes
core22    20231123   1033   latest/stable  canonical✓  base
firefox   120.0      3358   latest/stable  mozilla✓    -
"#;

        let packages = pm.parse_list_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "core22");
        assert!(packages[0].installed);
    }
}
