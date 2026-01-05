//! Flatpak package manager integration

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

/// Flatpak package manager
pub struct FlatpakPackageManager {
    flatpak_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl FlatpakPackageManager {
    /// Create a new Flatpak package manager
    pub async fn new() -> Self {
        let flatpak_path = Executable::new("flatpak")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/flatpak"));

        let sudo_path = Executable::new("sudo").find();

        Self {
            flatpak_path,
            sudo_path,
        }
    }

    /// Run flatpak command
    async fn run_flatpak(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.flatpak_path)
            .args(args)
            .output()
            .await
            .context("Failed to run flatpak command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("flatpak command failed: {}", stderr)
        }
    }

    /// Run flatpak command with sudo (for system-wide installs)
    async fn run_flatpak_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.flatpak_path);
            cmd
        } else {
            Command::new(&self.flatpak_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run flatpak command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("flatpak command failed: {}", stderr)
        }
    }

    /// Parse flatpak search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let line = line.trim();
            if line.is_empty() {
                continue;
            }

            // Format: Name	Description	Application ID	Version	Branch	Remotes
            let parts: Vec<&str> = line.split('\t').collect();
            if parts.len() < 3 {
                continue;
            }

            let name = parts[0].to_string();
            let description = if !parts[1].is_empty() {
                Some(parts[1].to_string())
            } else {
                None
            };
            let app_id = parts[2].to_string();
            let version = parts.get(3).and_then(|v| {
                if v.is_empty() {
                    None
                } else {
                    Some(v.to_string())
                }
            });

            packages.push(NativePackage {
                name: app_id,
                version,
                description: Some(format!(
                    "{}{}",
                    name,
                    description.map(|d| format!(" - {}", d)).unwrap_or_default()
                )),
                arch: None,
                repo: Some("flatpak".to_string()),
                popularity: None,
                installed: false,
            });
        }

        packages
    }

    /// Parse flatpak list output
    #[allow(dead_code)]
    fn parse_list_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let line = line.trim();
            if line.is_empty() {
                continue;
            }

            // Format: Name	Application ID	Version	Branch	Installation
            let parts: Vec<&str> = line.split('\t').collect();
            if parts.len() < 2 {
                continue;
            }

            let display_name = parts[0].to_string();
            let app_id = parts[1].to_string();
            let version = parts.get(2).and_then(|v| {
                if v.is_empty() {
                    None
                } else {
                    Some(v.to_string())
                }
            });

            packages.push(NativePackage {
                name: app_id,
                version,
                description: Some(display_name),
                arch: None,
                repo: Some("flatpak".to_string()),
                popularity: None,
                installed: true,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for FlatpakPackageManager {
    fn name(&self) -> &str {
        "flatpak"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_flatpak(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        let result = self.run_flatpak(&["install", "--user", "-y", name]).await;
        if result.is_err() {
            self.run_flatpak_sudo(&["install", "--system", "-y", name])
                .await?;
        }
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        let result = self.run_flatpak(&["uninstall", "--user", "-y", name]).await;
        if result.is_err() {
            self.run_flatpak_sudo(&["uninstall", "--system", "-y", name])
                .await?;
        }
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let user_check = self.run_flatpak(&["info", "--user", name]).await;
        if user_check.is_ok() {
            return Ok(true);
        }

        let system_check = self.run_flatpak(&["info", "--system", name]).await;
        Ok(system_check.is_ok())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_flatpak(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                pkg.repo = Some("flatpak".to_string());
                pkg.installed = true;

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" => pkg.version = Some(value.to_string()),
                            "Description" | "Subject" => pkg.description = Some(value.to_string()),
                            "Arch" => pkg.arch = Some(value.to_string()),
                            _ => {}
                        }
                    }
                }

                Ok(Some(pkg))
            }
            Err(_) => {
                let search_output = self.run_flatpak(&["search", name]).await;
                if let Ok(search) = search_output {
                    let packages = self.parse_search_output(&search);
                    let pkg = packages.into_iter().find(|p| p.name == name);
                    return Ok(pkg);
                }
                Ok(None)
            }
        }
    }

    async fn update_db(&self) -> Result<()> {
        let _ = self.run_flatpak(&["update", "--appstream"]).await;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = FlatpakPackageManager {
            flatpak_path: PathBuf::from("/usr/bin/flatpak"),
            sudo_path: None,
        };

        let output = "Micro\tA modern and intuitive terminal-based text editor\tio.github.nickvergessen.micro\t2.0.11\tstable\tflathub\nVisual Studio Code\tCode Editing. Redefined.\tcom.visualstudio.code\t1.84.0\tstable\tflathub";

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "io.github.nickvergessen.micro");
        assert_eq!(packages[1].name, "com.visualstudio.code");
    }
}
