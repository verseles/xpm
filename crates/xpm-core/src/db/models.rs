//! Database models for XPM

use chrono::{DateTime, Utc};
use native_db::*;
use native_model::native_model;
use serde::{Deserialize, Serialize};

/// Package model representing a package in the XPM database
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[native_model(id = 1, version = 1)]
#[native_db]
pub struct Package {
    /// Unique identifier
    #[primary_key]
    pub id: u64,

    /// Package name (unique index)
    #[secondary_key(unique)]
    pub name: String,

    /// Path to the package script
    pub script: Option<String>,

    /// Package description
    pub desc: Option<String>,

    /// Package version
    pub version: Option<String>,

    /// User-friendly title
    pub title: Option<String>,

    /// Package URL/homepage
    pub url: Option<String>,

    /// Supported architectures
    pub arch: Vec<String>,

    /// Supported installation methods
    pub methods: Vec<String>,

    /// Default installation methods
    pub defaults: Vec<String>,

    /// Installed version (None if not installed)
    pub installed: Option<String>,

    /// Method used for installation
    pub method: Option<String>,

    /// Channel used for installation
    pub channel: Option<String>,

    /// Whether this is a native package (from system PM)
    pub is_native: bool,

    /// Repository ID this package belongs to
    pub repo_id: Option<u64>,
}

impl Package {
    /// Create a new package with just a name
    pub fn new(name: impl Into<String>) -> Self {
        Self {
            id: 0,
            name: name.into(),
            script: None,
            desc: None,
            version: None,
            title: None,
            url: None,
            arch: Vec::new(),
            methods: Vec::new(),
            defaults: Vec::new(),
            installed: None,
            method: None,
            channel: None,
            is_native: false,
            repo_id: None,
        }
    }

    /// Check if package is installed
    pub fn is_installed(&self) -> bool {
        self.installed.is_some()
    }

    /// Check if package supports a specific architecture
    pub fn supports_arch(&self, arch: &str) -> bool {
        self.arch.is_empty() || self.arch.contains(&"any".to_string()) || self.arch.contains(&arch.to_string())
    }

    /// Check if package supports a specific installation method
    pub fn supports_method(&self, method: &str) -> bool {
        self.methods.contains(&method.to_string()) || self.defaults.contains(&method.to_string())
    }
}

/// Repository model representing a package source
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[native_model(id = 2, version = 1)]
#[native_db]
pub struct Repo {
    /// Unique identifier
    #[primary_key]
    pub id: u64,

    /// Repository URL (unique)
    #[secondary_key(unique)]
    pub url: String,

    /// Local path where repo is cloned
    pub local_path: Option<String>,

    /// Last sync timestamp
    pub last_sync: Option<DateTime<Utc>>,
}

impl Repo {
    /// Create a new repository
    pub fn new(url: impl Into<String>) -> Self {
        Self {
            id: 0,
            url: url.into(),
            local_path: None,
            last_sync: None,
        }
    }
}

/// Key-Value setting with optional expiration
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[native_model(id = 3, version = 1)]
#[native_db]
pub struct Setting {
    /// Unique identifier
    #[primary_key]
    pub id: u64,

    /// Setting key (unique, lowercase)
    #[secondary_key(unique)]
    pub key: String,

    /// Setting value (JSON serialized)
    pub value: String,

    /// Expiration timestamp (None = never expires)
    pub expires_at: Option<DateTime<Utc>>,
}

impl Setting {
    /// Create a new setting
    pub fn new(key: impl Into<String>, value: impl Into<String>) -> Self {
        Self {
            id: 0,
            key: key.into().to_lowercase(),
            value: value.into(),
            expires_at: None,
        }
    }

    /// Create a setting with expiration
    pub fn with_expiry(key: impl Into<String>, value: impl Into<String>, expires_at: DateTime<Utc>) -> Self {
        Self {
            id: 0,
            key: key.into().to_lowercase(),
            value: value.into(),
            expires_at: Some(expires_at),
        }
    }

    /// Check if setting is expired
    pub fn is_expired(&self) -> bool {
        match self.expires_at {
            Some(expires) => Utc::now() > expires,
            None => false,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_package_new() {
        let pkg = Package::new("test-package");
        assert_eq!(pkg.name, "test-package");
        assert!(!pkg.is_installed());
    }

    #[test]
    fn test_package_supports_arch() {
        let mut pkg = Package::new("test");
        assert!(pkg.supports_arch("x86_64")); // Empty arch means all supported

        pkg.arch = vec!["x86_64".to_string(), "aarch64".to_string()];
        assert!(pkg.supports_arch("x86_64"));
        assert!(!pkg.supports_arch("armv7"));

        pkg.arch = vec!["any".to_string()];
        assert!(pkg.supports_arch("anything"));
    }

    #[test]
    fn test_setting_expiry() {
        let setting = Setting::new("test", "value");
        assert!(!setting.is_expired());

        let expired = Setting::with_expiry(
            "test",
            "value",
            Utc::now() - chrono::Duration::hours(1),
        );
        assert!(expired.is_expired());
    }
}
