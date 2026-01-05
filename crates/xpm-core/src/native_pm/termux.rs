//! Termux (pkg) package manager integration (Android)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

/// Termux package manager (pkg/apt wrapper for Android)
pub struct TermuxPackageManager {
    pkg_path: PathBuf,
}

impl TermuxPackageManager {
    /// Create a new Termux package manager
    pub async fn new() -> Self {
        let pkg_path = Executable::new("pkg")
            .find()
            .or_else(|| Executable::new("apt").find())
            .unwrap_or_else(|| PathBuf::from("/data/data/com.termux/files/usr/bin/pkg"));

        Self { pkg_path }
    }

    /// Run pkg command
    async fn run_pkg(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.pkg_path)
            .args(args)
            .output()
            .await
            .context("Failed to run pkg command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("pkg command failed: {}", stderr)
        }
    }

    /// Parse pkg search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for raw_line in output.lines() {
            if raw_line.starts_with(' ') || raw_line.starts_with('\t') {
                continue;
            }

            let line = raw_line.trim();
            if line.is_empty()
                || line.starts_with("Sorting")
                || line.starts_with("Full Text")
                || line.ends_with("Done")
            {
                continue;
            }

            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.is_empty() {
                continue;
            }

            let name_part = parts[0];
            let name = name_part.split('/').next().unwrap_or(name_part);

            let version = parts.get(1).map(|s| s.to_string());
            let installed = line.contains("[installed");

            packages.push(NativePackage {
                name: name.to_string(),
                version,
                description: None,
                arch: parts.get(2).map(|s| s.to_string()),
                repo: Some("termux".to_string()),
                popularity: None,
                installed,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for TermuxPackageManager {
    fn name(&self) -> &str {
        "termux"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_pkg(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_pkg(&["install", "-y", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_pkg(&["uninstall", "-y", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new("dpkg").args(["-s", name]).output().await?;
        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_pkg(&["show", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                pkg.repo = Some("termux".to_string());

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
        self.run_pkg(&["update"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = TermuxPackageManager {
            pkg_path: PathBuf::from("/data/data/com.termux/files/usr/bin/pkg"),
        };

        let output = r#"Sorting... Done
Full Text Search... Done
micro/stable 2.0.11 aarch64
  Modern and intuitive terminal-based text editor

nano/stable 7.2-1 aarch64 [installed]
  Small, friendly text editor
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "micro");
        assert!(!packages[0].installed);
        assert_eq!(packages[1].name, "nano");
        assert!(packages[1].installed);
    }
}
