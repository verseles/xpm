//! Repository management module

use crate::db::{Database, Package, Repo};
use crate::os::dirs::XpmDirs;
use crate::script::{BashScript, ScriptMetadata};
use crate::utils::slugify::slugify;
use crate::DEFAULT_REPO;
use anyhow::{Context, Result};
use chrono::Utc;
use git2::Repository;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

/// Repository manager
pub struct Repositories;

impl Repositories {
    /// Get directory for a repository
    pub fn dir(repo_slug: &str, package: Option<&str>) -> Result<PathBuf> {
        let repos_dir = XpmDirs::repos_dir()?;
        let mut path = repos_dir.join(repo_slug);
        if let Some(pkg) = package {
            path = path.join(pkg);
        }
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Add or update a repository
    pub async fn add_repo(url: &str) -> Result<Repo> {
        let slug = slugify(url);
        let local_path = Self::dir(&slug, None)?;

        // Clone or pull
        if Self::is_git(&local_path) {
            Self::pull(&local_path).await?;
        } else {
            Self::clone(url, &local_path).await?;
        }

        // Save to database
        let db = Database::instance()?;
        let mut repo = Repo::new(url);
        repo.local_path = Some(local_path.to_string_lossy().to_string());
        repo.last_sync = Some(Utc::now());

        db.upsert_repo(repo)
    }

    /// Add the default popular repository
    pub async fn add_default() -> Result<Repo> {
        Self::add_repo(DEFAULT_REPO).await
    }

    /// Get all repositories
    pub fn all_repos() -> Result<Vec<Repo>> {
        let db = Database::instance()?;
        db.get_all_repos()
    }

    /// Remove a repository
    pub async fn remove_repo(url: &str) -> Result<bool> {
        let db = Database::instance()?;

        // Delete local directory
        let slug = slugify(url);
        let local_path = Self::dir(&slug, None)?;
        if local_path.exists() {
            tokio::fs::remove_dir_all(&local_path).await?;
        }

        db.delete_repo(url)
    }

    /// Pull all repositories
    pub async fn pull_all() -> Result<()> {
        let repos = Self::all_repos()?;

        // If no repos, add default
        if repos.is_empty() {
            Self::add_default().await?;
            return Ok(());
        }

        for repo in repos {
            let slug = slugify(&repo.url);
            let local_path = Self::dir(&slug, None)?;

            if Self::is_git(&local_path) {
                Self::pull(&local_path).await?;
            } else {
                Self::clone(&repo.url, &local_path).await?;
            }
        }

        Ok(())
    }

    /// Index all packages from repositories
    pub async fn index() -> Result<usize> {
        let db = Database::instance()?;

        // Delete non-installed packages
        db.delete_uninstalled_packages()?;

        // Pull latest
        Self::pull_all().await?;

        // Index packages
        let repos = Self::all_repos()?;
        let mut indexed = 0;

        for repo in repos {
            let slug = slugify(&repo.url);
            let local_path = Self::dir(&slug, None)?;

            // Find all package directories
            for entry in WalkDir::new(&local_path)
                .min_depth(1)
                .max_depth(1)
                .into_iter()
                .filter_map(|e| e.ok())
            {
                if !entry.file_type().is_dir() {
                    continue;
                }

                let pkg_name = entry.file_name().to_string_lossy().to_string();

                // Skip hidden directories
                if pkg_name.starts_with('.') {
                    continue;
                }

                // Find package script
                let script_path = entry.path().join(format!("{}.bash", pkg_name));
                if !script_path.exists() {
                    continue;
                }

                // Parse script metadata
                let script = BashScript::new(&script_path);
                if !script.exists() {
                    continue;
                }

                let metadata = ScriptMetadata::from_script(&script);

                // Create package
                let mut package = Package::new(&pkg_name);
                package.script = Some(script_path.to_string_lossy().to_string());
                package.desc = metadata.desc;
                package.version = metadata.version;
                package.title = metadata.title;
                package.url = metadata.url;
                package.arch = metadata.archs;
                package.methods = metadata.methods;
                package.defaults = metadata.defaults;
                package.repo_id = Some(repo.id);

                // Upsert to database
                db.upsert_package(package)?;
                indexed += 1;
            }
        }

        Ok(indexed)
    }

    /// Check if path is a git repository
    fn is_git(path: &Path) -> bool {
        path.join(".git").exists()
    }

    /// Clone a repository
    async fn clone(url: &str, path: &Path) -> Result<()> {
        let url = url.to_string();
        let path = path.to_path_buf();

        tokio::task::spawn_blocking(move || {
            Repository::clone(&url, &path)
                .context("Failed to clone repository")
                .map(|_| ())
        })
        .await?
    }

    /// Pull a repository
    async fn pull(path: &Path) -> Result<()> {
        let path = path.to_path_buf();

        tokio::task::spawn_blocking(move || -> Result<()> {
            let repo = Repository::open(&path).context("Failed to open repository")?;

            // Reset hard first
            let head = repo.head()?.peel_to_commit()?;
            repo.reset(head.as_object(), git2::ResetType::Hard, None)?;

            // Fetch
            let mut remote = repo.find_remote("origin")?;
            remote.fetch(&["main", "master"], None, None)?;

            // Get the fetch head
            let fetch_head = repo.find_reference("FETCH_HEAD")?;
            let fetch_commit = repo.reference_to_annotated_commit(&fetch_head)?;

            // Merge
            let (analysis, _) = repo.merge_analysis(&[&fetch_commit])?;

            if analysis.is_fast_forward() {
                let refname = format!("refs/heads/{}", "main");
                if let Ok(mut reference) = repo.find_reference(&refname) {
                    reference.set_target(fetch_commit.id(), "Fast-Forward")?;
                } else {
                    let refname = format!("refs/heads/{}", "master");
                    if let Ok(mut reference) = repo.find_reference(&refname) {
                        reference.set_target(fetch_commit.id(), "Fast-Forward")?;
                    }
                }
                repo.checkout_head(Some(git2::build::CheckoutBuilder::default().force()))?;
            }

            Ok(())
        })
        .await?
    }

    /// Get repository name from URL
    pub fn repo_name(url: &str) -> String {
        let parts: Vec<&str> = url.split('/').collect();
        if parts.len() >= 2 {
            let name = parts[parts.len() - 1].trim_end_matches(".git");
            let owner = parts[parts.len() - 2];
            format!("{}/{}", owner, name)
        } else {
            "unknown".to_string()
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_repo_name() {
        assert_eq!(
            Repositories::repo_name("https://github.com/verseles/xpm-popular.git"),
            "verseles/xpm-popular"
        );
        assert_eq!(
            Repositories::repo_name("https://github.com/user/repo"),
            "user/repo"
        );
    }

    #[test]
    fn test_slugify_url() {
        let slug = slugify("https://github.com/verseles/xpm-popular.git");
        assert!(!slug.contains('/'));
        assert!(!slug.contains(':'));
    }
}
