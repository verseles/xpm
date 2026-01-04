//! DNF package manager integration (Fedora/RHEL)

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use std::path::PathBuf;
use tokio::process::Command;

pub struct DnfPackageManager {
    dnf_path: PathBuf,
    sudo_path: Option<PathBuf>,
}

impl DnfPackageManager {
    pub async fn new() -> Self {
        let dnf_path = Executable::new("dnf")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/dnf"));

        let sudo_path = Executable::new("sudo").find();

        Self { dnf_path, sudo_path }
    }

    async fn run_dnf(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.dnf_path)
            .args(args)
            .output()
            .await
            .context("Failed to run dnf command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("dnf command failed: {}", stderr)
        }
    }

    async fn run_dnf_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if let Some(sudo) = &self.sudo_path {
            let mut cmd = Command::new(sudo);
            cmd.arg(&self.dnf_path);
            cmd
        } else {
            Command::new(&self.dnf_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run dnf command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("dnf command failed: {}", stderr)
        }
    }

    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();

        for line in output.lines() {
            if line.trim().is_empty() || line.starts_with('=') || line.starts_with("Last metadata") {
                continue;
            }

            let parts: Vec<&str> = line.split_whitespace().collect();
            if parts.len() >= 2 {
                let name_arch = parts[0];
                let name = name_arch.split('.').next().unwrap_or(name_arch);
                let version = parts.get(1).map(|s| s.to_string());

                packages.push(NativePackage {
                    name: name.to_string(),
                    version,
                    description: None,
                    arch: name_arch.split('.').nth(1).map(|s| s.to_string()),
                    repo: parts.get(2).map(|s| s.to_string()),
                    popularity: None,
                    installed: false,
                });
            }
        }

        packages
    }
}

#[async_trait]
impl NativePackageManager for DnfPackageManager {
    fn name(&self) -> &str {
        "dnf"
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_dnf(&["search", query]).await?;
        let mut packages = self.parse_search_output(&output);

        if let Some(limit) = limit {
            packages.truncate(limit);
        }

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_dnf_sudo(&["install", "-y", name]).await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_dnf_sudo(&["remove", "-y", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new("rpm")
            .args(["-q", name])
            .output()
            .await?;

        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_dnf(&["info", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" => pkg.version = Some(value.to_string()),
                            "Summary" | "Description" => pkg.description = Some(value.to_string()),
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
        self.run_dnf_sudo(&["makecache"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_search_output() {
        let pm = DnfPackageManager {
            dnf_path: PathBuf::from("/usr/bin/dnf"),
            sudo_path: None,
        };

        let output = "vim-enhanced.x86_64    2:9.0.1000-1.fc38    fedora\n\
                      vim-minimal.x86_64    2:9.0.1000-1.fc38    fedora";

        let packages = pm.parse_search_output(output);

        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "vim-enhanced");
        assert_eq!(packages[0].version, Some("2:9.0.1000-1.fc38".to_string()));
        assert_eq!(packages[0].arch, Some("x86_64".to_string()));
    }

    #[test]
    fn test_parse_search_output_skips_headers() {
        let pm = DnfPackageManager {
            dnf_path: PathBuf::from("/usr/bin/dnf"),
            sudo_path: None,
        };

        let output = "Last metadata expiration check: 0:30:00 ago\n\
                      ======================== Name Matched ========================\n\
                      git.x86_64    2.40.0-1.fc38    updates";

        let packages = pm.parse_search_output(output);

        assert_eq!(packages.len(), 1);
        assert_eq!(packages[0].name, "git");
    }

    #[test]
    fn test_name() {
        let pm = DnfPackageManager {
            dnf_path: PathBuf::from("/usr/bin/dnf"),
            sudo_path: None,
        };
        assert_eq!(pm.name(), "dnf");
    }
}
