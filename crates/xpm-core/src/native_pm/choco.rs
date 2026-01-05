//! Chocolatey package manager integration (Windows)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

/// Chocolatey package manager (Windows)
pub struct ChocoPackageManager {
    choco_path: PathBuf,
}

impl ChocoPackageManager {
    /// Create a new Chocolatey package manager
    pub async fn new() -> Self {
        let choco_path = Executable::new("choco")
            .find()
            .unwrap_or_else(|| PathBuf::from("C:\\ProgramData\\chocolatey\\bin\\choco.exe"));

        Self { choco_path }
    }

    /// Run choco command
    async fn run_choco(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.choco_path)
            .args(args)
            .output()
            .await
            .context("Failed to run choco command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("choco command failed: {}", stderr)
        }
    }

    /// Parse choco search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let line = line.trim();
            if line.is_empty()
                || line.starts_with("Chocolatey")
                || line.contains(" packages found")
                || line.contains("Did you mean")
            {
                continue;
            }

            // Format: packagename version [Approved]
            // Or: packagename version
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 2 {
                continue;
            }

            let name = parts[0].to_string();
            let version = Some(parts[1].to_string());

            packages.push(NativePackage {
                name,
                version,
                description: None,
                arch: None,
                repo: Some("chocolatey".to_string()),
                popularity: None,
                installed: false,
            });
        }

        packages
    }

    /// Parse choco list (local) output
    fn parse_list_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let line = line.trim();
            if line.is_empty()
                || line.starts_with("Chocolatey")
                || line.contains(" packages installed")
            {
                continue;
            }

            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() < 2 {
                continue;
            }

            packages.push(NativePackage {
                name: parts[0].to_string(),
                version: Some(parts[1].to_string()),
                description: None,
                arch: None,
                repo: Some("chocolatey".to_string()),
                popularity: None,
                installed: true,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for ChocoPackageManager {
    fn name(&self) -> &str {
        "choco"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let mut args = vec!["search", query, "--limit-output"];
        let limit_str;
        if let Some(limit) = limit {
            limit_str = limit.to_string();
            args.push("--page-size");
            args.push(&limit_str);
        }

        let output = self.run_choco(&args).await?;
        let packages = self.parse_search_output(&output);

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_choco(&["install", name, "-y", "--no-progress"])
            .await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_choco(&["uninstall", name, "-y", "--no-progress"])
            .await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = self.run_choco(&["list", "--local-only", name]).await?;
        Ok(output.contains(name))
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_choco(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                pkg.repo = Some("chocolatey".to_string());

                for line in output.lines() {
                    let line = line.trim();
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Title" => {
                                if let Some((_, ver)) = value.split_once('|') {
                                    pkg.version = Some(ver.trim().to_string());
                                }
                            }
                            "Version" => pkg.version = Some(value.to_string()),
                            "Summary" | "Description" => {
                                pkg.description = Some(value.to_string())
                            }
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
        Ok(())
    }
}

/// Scoop package manager (Windows alternative to Chocolatey)
pub struct ScoopPackageManager {
    scoop_path: PathBuf,
}

impl ScoopPackageManager {
    /// Create a new Scoop package manager
    pub async fn new() -> Self {
        let scoop_path = Executable::new("scoop")
            .find()
            .unwrap_or_else(|| {
                let home = std::env::var("USERPROFILE").unwrap_or_else(|_| "C:\\Users\\Default".to_string());
                PathBuf::from(format!("{}\\scoop\\shims\\scoop.cmd", home))
            });

        Self { scoop_path }
    }

    /// Run scoop command
    async fn run_scoop(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.scoop_path)
            .args(args)
            .output()
            .await
            .context("Failed to run scoop command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("scoop command failed: {}", stderr)
        }
    }

    /// Parse scoop search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with("Results") || line.starts_with("'") {
                continue;
            }

            // Format: name (version) [bucket]
            // Or just: name (version)
            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.is_empty() {
                continue;
            }

            let name = parts[0].to_string();
            let version = parts.get(1).and_then(|v| {
                let v = v.trim_matches(|c| c == '(' || c == ')');
                if v.is_empty() {
                    None
                } else {
                    Some(v.to_string())
                }
            });

            packages.push(NativePackage {
                name,
                version,
                description: None,
                arch: None,
                repo: Some("scoop".to_string()),
                popularity: None,
                installed: false,
            });
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for ScoopPackageManager {
    fn name(&self) -> &str {
        "scoop"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_scoop(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_scoop(&["install", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_scoop(&["uninstall", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = self.run_scoop(&["list"]).await?;
        Ok(output.contains(name))
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_scoop(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);
                pkg.repo = Some("scoop".to_string());

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" => pkg.version = Some(value.to_string()),
                            "Description" => pkg.description = Some(value.to_string()),
                            "Installed" => pkg.installed = value == "Yes",
                            _ => {}
                        }
                    }
                }

                Ok(Some(pkg))
            }
            Err(_) => Ok(None),
        }
    }

    async fn update_db(&self) -> Result<()> {
        self.run_scoop(&["update"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_choco_parse_search_output() {
        let pm = ChocoPackageManager {
            choco_path: PathBuf::from("choco"),
        };

        let output = r#"Chocolatey v2.0.0
micro 2.0.11 [Approved]
neovim 0.9.4
2 packages found.
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "micro");
        assert_eq!(packages[0].version, Some("2.0.11".to_string()));
    }

    #[test]
    fn test_scoop_parse_search_output() {
        let pm = ScoopPackageManager {
            scoop_path: PathBuf::from("scoop"),
        };

        let output = r#"Results from local buckets...

Name    (0.0.1)
micro   (2.0.11)
neovim  (0.9.4)
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 3);
    }
}
