//! Version checking utilities

use anyhow::{Context, Result};
use semver::Version;
use serde::Deserialize;

/// GitHub release response
#[derive(Debug, Deserialize)]
struct GitHubRelease {
    tag_name: String,
    html_url: String,
    #[serde(default)]
    prerelease: bool,
    #[serde(default)]
    draft: bool,
}

/// Version checker for GitHub releases
pub struct VersionChecker {
    client: reqwest::Client,
}

impl Default for VersionChecker {
    fn default() -> Self {
        Self::new()
    }
}

impl VersionChecker {
    /// Create a new version checker
    pub fn new() -> Self {
        Self {
            client: reqwest::Client::builder()
                .user_agent(format!("xpm/{}", crate::VERSION))
                .timeout(std::time::Duration::from_secs(10))
                .build()
                .unwrap_or_else(|_| reqwest::Client::new()),
        }
    }

    /// Check for new version on GitHub
    pub async fn check_for_update(
        &self,
        repo: &str,
        current_version: &str,
    ) -> Result<Option<NewVersion>> {
        let current = Version::parse(current_version.trim_start_matches('v'))
            .context("Invalid current version")?;

        let latest = self.get_latest_release(repo).await?;

        if let Some(release) = latest {
            let latest_version = Version::parse(release.tag_name.trim_start_matches('v'))
                .context("Invalid release version")?;

            if latest_version > current {
                return Ok(Some(NewVersion {
                    version: latest_version.to_string(),
                    url: release.html_url,
                }));
            }
        }

        Ok(None)
    }

    /// Get the latest release from GitHub
    async fn get_latest_release(&self, repo: &str) -> Result<Option<GitHubRelease>> {
        let url = format!("https://api.github.com/repos/{}/releases/latest", repo);

        let response = self.client.get(&url).send().await?;

        if response.status().is_success() {
            let release: GitHubRelease = response.json().await?;
            if !release.draft && !release.prerelease {
                return Ok(Some(release));
            }
        }

        Ok(None)
    }

    /// Get all releases from GitHub
    pub async fn get_all_releases(&self, repo: &str) -> Result<Vec<ReleaseInfo>> {
        let url = format!("https://api.github.com/repos/{}/releases", repo);

        let response = self.client.get(&url).send().await?;

        if response.status().is_success() {
            let releases: Vec<GitHubRelease> = response.json().await?;
            return Ok(releases
                .into_iter()
                .filter(|r| !r.draft)
                .map(|r| ReleaseInfo {
                    version: r.tag_name.trim_start_matches('v').to_string(),
                    url: r.html_url,
                    prerelease: r.prerelease,
                })
                .collect());
        }

        Ok(Vec::new())
    }
}

/// Information about a new version
#[derive(Debug, Clone)]
pub struct NewVersion {
    /// Version string
    pub version: String,
    /// Release URL
    pub url: String,
}

/// Information about a release
#[derive(Debug, Clone)]
pub struct ReleaseInfo {
    /// Version string
    pub version: String,
    /// Release URL
    pub url: String,
    /// Is this a prerelease
    pub prerelease: bool,
}

/// Compare two semantic versions
pub fn compare_versions(a: &str, b: &str) -> std::cmp::Ordering {
    let va = Version::parse(a.trim_start_matches('v')).ok();
    let vb = Version::parse(b.trim_start_matches('v')).ok();

    match (va, vb) {
        (Some(va), Some(vb)) => va.cmp(&vb),
        (Some(_), None) => std::cmp::Ordering::Greater,
        (None, Some(_)) => std::cmp::Ordering::Less,
        (None, None) => a.cmp(b),
    }
}

/// Check if version a is newer than version b
pub fn is_newer(a: &str, b: &str) -> bool {
    compare_versions(a, b) == std::cmp::Ordering::Greater
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_compare_versions() {
        assert_eq!(
            compare_versions("1.0.0", "0.9.0"),
            std::cmp::Ordering::Greater
        );
        assert_eq!(
            compare_versions("1.0.0", "1.0.0"),
            std::cmp::Ordering::Equal
        );
        assert_eq!(
            compare_versions("1.0.0", "1.0.1"),
            std::cmp::Ordering::Less
        );
    }

    #[test]
    fn test_compare_versions_with_v_prefix() {
        assert_eq!(
            compare_versions("v1.0.0", "v0.9.0"),
            std::cmp::Ordering::Greater
        );
        assert_eq!(
            compare_versions("v1.0.0", "1.0.0"),
            std::cmp::Ordering::Equal
        );
    }

    #[test]
    fn test_is_newer() {
        assert!(is_newer("2.0.0", "1.0.0"));
        assert!(!is_newer("1.0.0", "2.0.0"));
        assert!(!is_newer("1.0.0", "1.0.0"));
    }

    #[tokio::test]
    async fn test_version_checker() {
        let checker = VersionChecker::new();
        // This test requires network, so we just verify it doesn't panic
        let result = checker.check_for_update("verseles/xpm", "0.0.1").await;
        // Should either succeed or fail gracefully
        match result {
            Ok(Some(new_version)) => {
                assert!(!new_version.version.is_empty());
            }
            Ok(None) => {
                // No update available (or already latest)
            }
            Err(_) => {
                // Network error, that's OK for tests
            }
        }
    }
}
