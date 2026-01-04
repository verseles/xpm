//! Native package manager integration

mod apt;
mod detector;
mod pacman;

pub use apt::AptPackageManager;
pub use detector::detect_native_pm;
pub use pacman::PacmanPackageManager;

use anyhow::Result;
use async_trait::async_trait;

/// Native package representation
#[derive(Debug, Clone)]
pub struct NativePackage {
    /// Package name
    pub name: String,
    /// Version string
    pub version: Option<String>,
    /// Description
    pub description: Option<String>,
    /// Architecture
    pub arch: Option<String>,
    /// Repository name (e.g., "extra", "aur")
    pub repo: Option<String>,
    /// Popularity score (for AUR)
    pub popularity: Option<i32>,
    /// Is installed
    pub installed: bool,
}

impl NativePackage {
    /// Create a new native package
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            name: name.into(),
            version: None,
            description: None,
            arch: None,
            repo: None,
            popularity: None,
            installed: false,
        }
    }

    /// Builder pattern for version
    pub fn with_version(mut self, version: impl Into<String>) -> Self {
        self.version = Some(version.into());
        self
    }

    /// Builder pattern for description
    pub fn with_description(mut self, desc: impl Into<String>) -> Self {
        self.description = Some(desc.into());
        self
    }

    /// Builder pattern for repo
    pub fn with_repo(mut self, repo: impl Into<String>) -> Self {
        self.repo = Some(repo.into());
        self
    }

    /// Builder pattern for popularity
    pub fn with_popularity(mut self, pop: i32) -> Self {
        self.popularity = Some(pop);
        self
    }

    /// Check if this is an AUR package
    pub fn is_aur(&self) -> bool {
        self.repo.as_deref() == Some("aur")
    }
}

/// Trait for native package managers
#[async_trait]
pub trait NativePackageManager: Send + Sync {
    /// Get package manager name
    fn name(&self) -> &str;

    /// Search for packages
    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>>;

    /// Install a package
    async fn install(&self, name: &str) -> Result<()>;

    /// Remove a package
    async fn remove(&self, name: &str) -> Result<()>;

    /// Check if package is installed
    async fn is_installed(&self, name: &str) -> Result<bool>;

    /// Get package info
    async fn get(&self, name: &str) -> Result<Option<NativePackage>>;

    /// Update package database
    async fn update_db(&self) -> Result<()>;
}

/// Wrapper enum for dynamic dispatch
pub enum NativePM {
    Apt(AptPackageManager),
    Pacman(PacmanPackageManager),
}

#[async_trait]
impl NativePackageManager for NativePM {
    fn name(&self) -> &str {
        match self {
            NativePM::Apt(pm) => pm.name(),
            NativePM::Pacman(pm) => pm.name(),
        }
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        match self {
            NativePM::Apt(pm) => pm.search(query, limit).await,
            NativePM::Pacman(pm) => pm.search(query, limit).await,
        }
    }

    async fn install(&self, name: &str) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.install(name).await,
            NativePM::Pacman(pm) => pm.install(name).await,
        }
    }

    async fn remove(&self, name: &str) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.remove(name).await,
            NativePM::Pacman(pm) => pm.remove(name).await,
        }
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        match self {
            NativePM::Apt(pm) => pm.is_installed(name).await,
            NativePM::Pacman(pm) => pm.is_installed(name).await,
        }
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        match self {
            NativePM::Apt(pm) => pm.get(name).await,
            NativePM::Pacman(pm) => pm.get(name).await,
        }
    }

    async fn update_db(&self) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.update_db().await,
            NativePM::Pacman(pm) => pm.update_db().await,
        }
    }
}
