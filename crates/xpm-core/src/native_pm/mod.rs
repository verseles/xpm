//! Native package manager integration

mod apt;
mod brew;
mod choco;
mod detector;
mod dnf;
mod flatpak;
mod pacman;
mod snap;
mod swupd;
mod termux;
mod zypper;

pub use apt::AptPackageManager;
pub use brew::BrewPackageManager;
pub use choco::{ChocoPackageManager, ScoopPackageManager};
pub use detector::detect_native_pm;
pub use dnf::DnfPackageManager;
pub use flatpak::FlatpakPackageManager;
pub use pacman::PacmanPackageManager;
pub use snap::SnapPackageManager;
pub use swupd::SwupdPackageManager;
pub use termux::TermuxPackageManager;
pub use zypper::ZypperPackageManager;

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

    /// Whether search results are pre-sorted by relevance (most relevant last)
    fn results_pre_sorted(&self) -> bool {
        false
    }
}

pub enum NativePM {
    Apt(AptPackageManager),
    Pacman(PacmanPackageManager),
    Dnf(DnfPackageManager),
    Zypper(ZypperPackageManager),
    Brew(BrewPackageManager),
    Swupd(SwupdPackageManager),
    Termux(TermuxPackageManager),
    Snap(SnapPackageManager),
    Flatpak(FlatpakPackageManager),
    Choco(ChocoPackageManager),
    Scoop(ScoopPackageManager),
}

#[async_trait]
impl NativePackageManager for NativePM {
    fn name(&self) -> &str {
        match self {
            NativePM::Apt(pm) => pm.name(),
            NativePM::Pacman(pm) => pm.name(),
            NativePM::Dnf(pm) => pm.name(),
            NativePM::Zypper(pm) => pm.name(),
            NativePM::Brew(pm) => pm.name(),
            NativePM::Swupd(pm) => pm.name(),
            NativePM::Termux(pm) => pm.name(),
            NativePM::Snap(pm) => pm.name(),
            NativePM::Flatpak(pm) => pm.name(),
            NativePM::Choco(pm) => pm.name(),
            NativePM::Scoop(pm) => pm.name(),
        }
    }

    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>> {
        match self {
            NativePM::Apt(pm) => pm.search(query, limit).await,
            NativePM::Pacman(pm) => pm.search(query, limit).await,
            NativePM::Dnf(pm) => pm.search(query, limit).await,
            NativePM::Zypper(pm) => pm.search(query, limit).await,
            NativePM::Brew(pm) => pm.search(query, limit).await,
            NativePM::Swupd(pm) => pm.search(query, limit).await,
            NativePM::Termux(pm) => pm.search(query, limit).await,
            NativePM::Snap(pm) => pm.search(query, limit).await,
            NativePM::Flatpak(pm) => pm.search(query, limit).await,
            NativePM::Choco(pm) => pm.search(query, limit).await,
            NativePM::Scoop(pm) => pm.search(query, limit).await,
        }
    }

    async fn install(&self, name: &str) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.install(name).await,
            NativePM::Pacman(pm) => pm.install(name).await,
            NativePM::Dnf(pm) => pm.install(name).await,
            NativePM::Zypper(pm) => pm.install(name).await,
            NativePM::Brew(pm) => pm.install(name).await,
            NativePM::Swupd(pm) => pm.install(name).await,
            NativePM::Termux(pm) => pm.install(name).await,
            NativePM::Snap(pm) => pm.install(name).await,
            NativePM::Flatpak(pm) => pm.install(name).await,
            NativePM::Choco(pm) => pm.install(name).await,
            NativePM::Scoop(pm) => pm.install(name).await,
        }
    }

    async fn remove(&self, name: &str) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.remove(name).await,
            NativePM::Pacman(pm) => pm.remove(name).await,
            NativePM::Dnf(pm) => pm.remove(name).await,
            NativePM::Zypper(pm) => pm.remove(name).await,
            NativePM::Brew(pm) => pm.remove(name).await,
            NativePM::Swupd(pm) => pm.remove(name).await,
            NativePM::Termux(pm) => pm.remove(name).await,
            NativePM::Snap(pm) => pm.remove(name).await,
            NativePM::Flatpak(pm) => pm.remove(name).await,
            NativePM::Choco(pm) => pm.remove(name).await,
            NativePM::Scoop(pm) => pm.remove(name).await,
        }
    }

    async fn is_installed(&self, name: &str) -> Result<bool> {
        match self {
            NativePM::Apt(pm) => pm.is_installed(name).await,
            NativePM::Pacman(pm) => pm.is_installed(name).await,
            NativePM::Dnf(pm) => pm.is_installed(name).await,
            NativePM::Zypper(pm) => pm.is_installed(name).await,
            NativePM::Brew(pm) => pm.is_installed(name).await,
            NativePM::Swupd(pm) => pm.is_installed(name).await,
            NativePM::Termux(pm) => pm.is_installed(name).await,
            NativePM::Snap(pm) => pm.is_installed(name).await,
            NativePM::Flatpak(pm) => pm.is_installed(name).await,
            NativePM::Choco(pm) => pm.is_installed(name).await,
            NativePM::Scoop(pm) => pm.is_installed(name).await,
        }
    }

    async fn get(&self, name: &str) -> Result<Option<NativePackage>> {
        match self {
            NativePM::Apt(pm) => pm.get(name).await,
            NativePM::Pacman(pm) => pm.get(name).await,
            NativePM::Dnf(pm) => pm.get(name).await,
            NativePM::Zypper(pm) => pm.get(name).await,
            NativePM::Brew(pm) => pm.get(name).await,
            NativePM::Swupd(pm) => pm.get(name).await,
            NativePM::Termux(pm) => pm.get(name).await,
            NativePM::Snap(pm) => pm.get(name).await,
            NativePM::Flatpak(pm) => pm.get(name).await,
            NativePM::Choco(pm) => pm.get(name).await,
            NativePM::Scoop(pm) => pm.get(name).await,
        }
    }

    async fn update_db(&self) -> Result<()> {
        match self {
            NativePM::Apt(pm) => pm.update_db().await,
            NativePM::Pacman(pm) => pm.update_db().await,
            NativePM::Dnf(pm) => pm.update_db().await,
            NativePM::Zypper(pm) => pm.update_db().await,
            NativePM::Brew(pm) => pm.update_db().await,
            NativePM::Swupd(pm) => pm.update_db().await,
            NativePM::Termux(pm) => pm.update_db().await,
            NativePM::Snap(pm) => pm.update_db().await,
            NativePM::Flatpak(pm) => pm.update_db().await,
            NativePM::Choco(pm) => pm.update_db().await,
            NativePM::Scoop(pm) => pm.update_db().await,
        }
    }

    fn results_pre_sorted(&self) -> bool {
        match self {
            NativePM::Pacman(pm) => pm.results_pre_sorted(),
            _ => false,
        }
    }
}
