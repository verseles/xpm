//! XPM Core Library
//!
//! This crate provides the core functionality for XPM, the universal package manager.
//! It includes database models, OS abstractions, package manager integrations, and utilities.

pub mod db;
pub mod native_pm;
pub mod os;
pub mod repo;
pub mod script;
pub mod utils;

// Re-export commonly used types
pub use db::{Database, Package, Repo, Setting};
pub use native_pm::{NativePackage, NativePackageManager};
pub use os::{Architecture, OsInfo, OsType};
pub use utils::logger::Logger;

/// XPM version from Cargo.toml
pub const VERSION: &str = env!("CARGO_PKG_VERSION");

/// XPM name
pub const NAME: &str = "xpm";

/// XPM description
pub const DESCRIPTION: &str = "Universal package manager for any unix-like distro including macOS";

/// Default repository URL
pub const DEFAULT_REPO: &str = "https://github.com/verseles/xpm-popular.git";

/// Supported installation methods
pub const INSTALL_METHODS: &[(&str, &str)] = &[
    ("auto", "Automatically choose the best method or fallback to [any]"),
    ("any", "Use the generic method. Sometimes this is the best method"),
    ("apt", "Use apt or apt-like package manager"),
    ("flatpak", "Use flatpak package manager"),
    ("snap", "Use snap package manager"),
    ("appimage", "Use compiled binaries if available"),
    ("brew", "Use Homebrew package manager"),
    ("choco", "Use Chocolatey package manager"),
    ("dnf", "Use dnf or dnf-like package manager"),
    ("pacman", "Use pacman or pacman-like package manager"),
    ("zypper", "Use zypper package manager"),
    ("termux", "Use Termux package manager"),
    ("swupd", "Use swupd package manager"),
];
