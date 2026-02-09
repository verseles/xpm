//! Pacman package manager integration (Arch Linux)
//! Supports paru, yay, and pacman

use super::{NativePackage, NativePackageManager};
use crate::os::executable::Executable;
use anyhow::{Context, Result};
use async_trait::async_trait;
use regex::Regex;
use std::path::PathBuf;
use tokio::process::Command;

/// Pacman package manager (with AUR helper support)
pub struct PacmanPackageManager {
    /// Best available helper (paru > yay > pacman)
    helper_path: PathBuf,
    /// Helper name
    helper_name: String,
    /// Pacman path (for operations that need it)
    #[allow(dead_code)]
    pacman_path: PathBuf,
    /// Sudo path
    sudo_path: Option<PathBuf>,
}

impl PacmanPackageManager {
    /// Create a new Pacman package manager
    pub async fn new() -> Self {
        // Try AUR helpers first: Paru → Yay → Pacman
        let (helper_path, helper_name) = if let Some(paru) = Executable::new("paru").find() {
            (paru, "paru".to_string())
        } else if let Some(yay) = Executable::new("yay").find() {
            (yay, "yay".to_string())
        } else {
            let pacman = Executable::new("pacman")
                .find()
                .unwrap_or_else(|| PathBuf::from("/usr/bin/pacman"));
            (pacman.clone(), "pacman".to_string())
        };

        let pacman_path = Executable::new("pacman")
            .find()
            .unwrap_or_else(|| PathBuf::from("/usr/bin/pacman"));

        let sudo_path = Executable::new("sudo").find();

        Self {
            helper_path,
            helper_name,
            pacman_path,
            sudo_path,
        }
    }

    /// Check if using an AUR helper
    #[allow(dead_code)]
    fn has_aur(&self) -> bool {
        self.helper_name == "paru" || self.helper_name == "yay"
    }

    /// Check if sudo is needed (pacman needs sudo, AUR helpers don't)
    fn needs_sudo(&self) -> bool {
        self.helper_name == "pacman"
    }

    /// Run helper command
    async fn run_helper(&self, args: &[&str]) -> Result<String> {
        let output = Command::new(&self.helper_path)
            .args(args)
            .output()
            .await
            .context("Failed to run pacman command")?;

        Ok(String::from_utf8_lossy(&output.stdout).to_string())
    }

    /// Run helper with sudo if needed
    async fn run_helper_sudo(&self, args: &[&str]) -> Result<String> {
        let mut cmd = if self.needs_sudo() {
            if let Some(sudo) = &self.sudo_path {
                let mut cmd = Command::new(sudo);
                cmd.arg(&self.helper_path);
                cmd
            } else {
                Command::new(&self.helper_path)
            }
        } else {
            Command::new(&self.helper_path)
        };

        let output = cmd
            .args(args)
            .output()
            .await
            .context("Failed to run pacman command")?;

        if output.status.success() {
            Ok(String::from_utf8_lossy(&output.stdout).to_string())
        } else {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("pacman command failed: {}", stderr)
        }
    }

    /// Parse search output
    fn parse_search_output(&self, output: &str) -> Vec<NativePackage> {
        let mut packages = Vec::new();
        let lines: Vec<&str> = output.lines().filter(|l| !l.is_empty()).collect();

        let paru_pattern = Regex::new(r"\[\+(\d+)\s+~([0-9\.]+)\]").ok();
        let yay_pattern = Regex::new(r"\(\+(\d+)\s+([0-9\.]+)\)").ok();

        let mut i = 0;
        while i < lines.len() {
            let line = lines[i];
            let parts: Vec<&str> = line.split_whitespace().collect();

            if parts.is_empty() {
                i += 1;
                continue;
            }

            // Parse: repo/package version [stats]
            let repo_pkg: Vec<&str> = parts[0].split('/').collect();
            if repo_pkg.len() < 2 {
                i += 1;
                continue;
            }

            let repo = repo_pkg[0].to_string();
            let name = repo_pkg[1].to_string();
            let version = parts.get(1).map(|s| s.to_string());

            // Parse popularity for AUR packages (votes count, not score)
            let mut popularity = None;
            if repo == "aur" {
                // Capture group 1 = votes (integer), group 2 = score (float)
                if let Some(ref pat) = paru_pattern {
                    if let Some(cap) = pat.captures(line) {
                        if let Some(votes) = cap.get(1) {
                            if let Ok(v) = votes.as_str().parse::<i32>() {
                                popularity = Some(v);
                            }
                        }
                    }
                }
                if popularity.is_none() {
                    if let Some(ref pat) = yay_pattern {
                        if let Some(cap) = pat.captures(line) {
                            if let Some(votes) = cap.get(1) {
                                if let Ok(v) = votes.as_str().parse::<i32>() {
                                    popularity = Some(v);
                                }
                            }
                        }
                    }
                }
            }

            // Get description from next line if it starts with whitespace
            let mut description = None;
            if i + 1 < lines.len() {
                let next_line = lines[i + 1];
                if next_line.starts_with(' ') || next_line.starts_with('\t') {
                    description = Some(next_line.trim().to_string());
                    i += 1;
                }
            }

            // Check if installed
            let installed = line.contains("[installed");

            packages.push(NativePackage {
                name,
                version,
                description,
                arch: None,
                repo: Some(repo),
                popularity,
                installed,
            });

            i += 1;
        }

        packages
    }

    /// Filter and sort packages
    /// Prioritizes official packages over AUR packages if limit is applied
    fn filter_and_sort_packages(&self, packages: &mut Vec<NativePackage>, limit: Option<usize>) {
        let mut official: Vec<_> = packages.iter().filter(|p| !p.is_aur()).cloned().collect();
        let mut aur: Vec<_> = packages.iter().filter(|p| p.is_aur()).cloned().collect();

        // Sort official by name
        official.sort_by(|a, b| a.name.cmp(&b.name));

        // Sort AUR by popularity (ascending, so most popular appears last/at bottom)
        aur.sort_by(|a, b| {
            let a_pop = a.popularity.unwrap_or(0);
            let b_pop = b.popularity.unwrap_or(0);
            a_pop.cmp(&b_pop)
        });

        // Apply limits if requested
        if let Some(limit) = limit {
            // If official packages exceed limit, truncate them
            if official.len() > limit {
                official.truncate(limit);
                aur.clear(); // No space for AUR
            } else {
                // If we have space for AUR packages, take the most popular ones
                let remaining_slots = limit - official.len();
                if aur.len() > remaining_slots {
                    // AUR is sorted by popularity ascending.
                    // We want the most popular ones, which are at the end.
                    // So we take the last `remaining_slots` elements.
                    let start_index = aur.len() - remaining_slots;
                    aur = aur.split_off(start_index);
                }
            }
        }

        // Combine: AUR first, then official
        // This way when displayed, user sees official first (at bottom/end of list),
        // then AUR above them.
        packages.clear();
        packages.extend(aur);
        packages.extend(official);
    }
}

#[async_trait]
impl NativePackageManager for PacmanPackageManager {
    fn name(&self) -> &str {
        &self.helper_name
    }

    fn results_pre_sorted(&self) -> bool {
        true
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        let output = self.run_helper(&["-Ss", "--noconfirm", query]).await?;
        let mut packages = self.parse_search_output(&output);

        // Sort and limit: prioritize official packages, then most popular AUR
        self.filter_and_sort_packages(&mut packages, limit);

        Ok(packages)
    }

    async fn install(&self, name: &str) -> Result<()> {
        self.run_helper_sudo(&["-S", "--noconfirm", "--needed", name])
            .await?;
        Ok(())
    }

    async fn remove(&self, name: &str) -> Result<()> {
        self.run_helper_sudo(&["-R", "--noconfirm", name]).await?;
        Ok(())
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        let output = Command::new(&self.helper_path)
            .args(["-Q", name])
            .output()
            .await?;

        Ok(output.status.success())
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        let output = self.run_helper(&["-Si", name]).await;

        match output {
            Ok(output) => {
                let mut pkg = NativePackage::new(name);

                for line in output.lines() {
                    if let Some((key, value)) = line.split_once(':') {
                        let value = value.trim();
                        match key.trim() {
                            "Version" | "Versão" => pkg.version = Some(value.to_string()),
                            "Description" | "Descrição" => {
                                pkg.description = Some(value.to_string())
                            }
                            "Architecture" | "Arquitetura" => pkg.arch = Some(value.to_string()),
                            "Repository" => pkg.repo = Some(value.to_string()),
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
        self.run_helper_sudo(&["-Sy"]).await?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_pm() -> PacmanPackageManager {
        PacmanPackageManager {
            helper_path: PathBuf::from("/usr/bin/paru"),
            helper_name: "paru".to_string(),
            pacman_path: PathBuf::from("/usr/bin/pacman"),
            sudo_path: Some(PathBuf::from("/usr/bin/sudo")),
        }
    }

    #[test]
    fn test_parse_search_output() {
        let pm = create_test_pm();

        let output = r#"extra/jq 1.7.1-1
    Command-line JSON processor
aur/jqp 0.5.0-1 [+67 ~2.84]
    A TUI playground to experiment and play with jq
core/base 3-1 [installed]
    Minimal package set to define a basic Arch Linux installation
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 3);

        assert_eq!(packages[0].name, "jq");
        assert_eq!(packages[0].repo, Some("extra".to_string()));
        assert!(!packages[0].is_aur());

        assert_eq!(packages[1].name, "jqp");
        assert_eq!(packages[1].repo, Some("aur".to_string()));
        assert!(packages[1].is_aur());
        assert_eq!(packages[1].popularity, Some(67)); // votes, not score

        assert_eq!(packages[2].name, "base");
        assert!(packages[2].installed);
    }

    #[test]
    fn test_filter_and_sort_packages() {
        let pm = create_test_pm();

        let mut packages = vec![
            NativePackage::new("zed").with_repo("extra"),
            NativePackage::new("aur-pkg1")
                .with_repo("aur")
                .with_popularity(100),
            NativePackage::new("abc").with_repo("core"),
            NativePackage::new("aur-pkg2")
                .with_repo("aur")
                .with_popularity(500),
        ];

        // No limit
        pm.filter_and_sort_packages(&mut packages, None);

        // AUR should come first (sorted by popularity ascending)
        assert!(packages[0].is_aur());
        assert_eq!(packages[0].popularity, Some(100));
        assert!(packages[1].is_aur());
        assert_eq!(packages[1].popularity, Some(500));

        // Official should come after (sorted by name)
        assert!(!packages[2].is_aur());
        assert_eq!(packages[2].name, "abc");
        assert!(!packages[3].is_aur());
        assert_eq!(packages[3].name, "zed");
    }

    #[test]
    fn test_filter_and_sort_packages_with_limit() {
        let pm = create_test_pm();

        let mut packages = vec![
            NativePackage::new("off1").with_repo("core"),
            NativePackage::new("off2").with_repo("extra"),
            NativePackage::new("aur1")
                .with_repo("aur")
                .with_popularity(10),
            NativePackage::new("aur2")
                .with_repo("aur")
                .with_popularity(20),
            NativePackage::new("aur3")
                .with_repo("aur")
                .with_popularity(30),
        ];

        // Limit = 3. Should keep 2 official + 1 best AUR (aur3)
        pm.filter_and_sort_packages(&mut packages, Some(3));

        assert_eq!(packages.len(), 3);
        // AUR first
        assert!(packages[0].is_aur());
        assert_eq!(packages[0].name, "aur3"); // Most popular AUR

        // Then official
        assert!(!packages[1].is_aur());
        assert_eq!(packages[1].name, "off1");
        assert!(!packages[2].is_aur());
        assert_eq!(packages[2].name, "off2");
    }

    #[test]
    fn test_filter_and_sort_packages_limit_only_official() {
        let pm = create_test_pm();

        let mut packages = vec![
            NativePackage::new("off1").with_repo("core"),
            NativePackage::new("off2").with_repo("extra"),
            NativePackage::new("off3").with_repo("extra"),
            NativePackage::new("aur1").with_repo("aur"),
        ];

        // Limit = 2. Should keep 2 official, 0 AUR.
        pm.filter_and_sort_packages(&mut packages, Some(2));

        assert_eq!(packages.len(), 2);
        assert_eq!(packages[0].name, "off1");
        assert_eq!(packages[1].name, "off2");
    }

    #[test]
    fn test_parse_yay_format() {
        let pm = create_test_pm();

        let output = r#"aur/neovim-git 0.10.0.r1+g1234567-1 (+320 5.67)
    Vim-fork focused on extensibility and agility (git version)
aur/neovim-nightly-bin 0.10.0-1 (+89 2.34)
    Nightly build of neovim
"#;

        let packages = pm.parse_search_output(output);
        assert_eq!(packages.len(), 2);

        assert_eq!(packages[0].name, "neovim-git");
        assert_eq!(packages[0].popularity, Some(320));
        assert!(packages[0].is_aur());

        assert_eq!(packages[1].name, "neovim-nightly-bin");
        assert_eq!(packages[1].popularity, Some(89));
    }

    #[test]
    fn test_results_pre_sorted() {
        let pm = create_test_pm();
        assert!(pm.results_pre_sorted());
    }
}
