//! Database models for XPM

use chrono::{DateTime, Utc};
use native_db::*;
use native_model::{native_model, Model};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::convert::TryInto;

/// Generate a stable ID from a string using SHA256
pub fn generate_stable_id(input: &str) -> u64 {
    let mut hasher = Sha256::new();
    hasher.update(input);
    let result = hasher.finalize();
    // Use the first 8 bytes for u64
    let bytes: [u8; 8] = result[0..8].try_into().unwrap_or_default();
    u64::from_be_bytes(bytes)
}

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

    #[secondary_key]
    pub desc: Option<String>,

    /// Package version
    pub version: Option<String>,

    #[secondary_key]
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
    #[secondary_key]
    pub installed: Option<String>,

    /// Method used for installation
    #[secondary_key]
    pub method: Option<String>,

    /// Channel used for installation
    #[secondary_key]
    pub channel: Option<String>,

    /// Whether this is a native package (from system PM)
    pub is_native: bool,

    /// Repository ID this package belongs to
    #[secondary_key]
    pub repo_id: Option<u64>,
}

impl Package {
    pub fn new(name: impl Into<String>) -> Self {
        let name_str = name.into();
        let id = Self::generate_id(&name_str);
        Self {
            id,
            name: name_str,
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

    fn generate_id(name: &str) -> u64 {
        generate_stable_id(name)
    }

    /// Check if package supports a specific architecture
    pub fn supports_arch(&self, arch: &str) -> bool {
        self.arch.is_empty()
            || self.arch.contains(&"any".to_string())
            || self.arch.contains(&arch.to_string())
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
        let url_str = url.into();
        let id = generate_stable_id(&url_str);
        Self {
            id,
            url: url_str,
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
        let key_lower = key.into().to_lowercase();
        Self {
            id: Self::generate_id(&key_lower),
            key: key_lower,
            value: value.into(),
            expires_at: None,
        }
    }

    fn generate_id(key: &str) -> u64 {
        generate_stable_id(key)
    }

    pub fn with_expiry(
        key: impl Into<String>,
        value: impl Into<String>,
        expires_at: DateTime<Utc>,
    ) -> Self {
        let key_lower = key.into().to_lowercase();
        Self {
            id: Self::generate_id(&key_lower),
            key: key_lower,
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

        let expired =
            Setting::with_expiry("test", "value", Utc::now() - chrono::Duration::hours(1));
        assert!(expired.is_expired());
    }

    #[test]
    fn test_stable_id_generation() {
        let id1 = generate_stable_id("test-package");
        let id2 = generate_stable_id("test-package");
        let id3 = generate_stable_id("other-package");

        assert_eq!(id1, id2);
        assert_ne!(id1, id3);

        // Ensure it's not using DefaultHasher
        // (This specific value depends on SHA256 of "test-package" which is constant)
        // echo -n "test-package" | sha256sum
        // a46c30a560c2b4f542e9fc7141ac40a3c52e9941216b90bab17237c82ce6306e
        // First 8 bytes: a4 6c 30 a5 60 c2 b4 f5
        // In u64 (big endian): 0xa46c30a560c2b4f5
        // = 11847898206556042485
        assert_eq!(id1, 0xa46c30a560c2b4f5);
    }

    #[test]
    fn test_repo_id_generation() {
        let repo = Repo::new("https://example.com");
        assert_ne!(repo.id, 0);

        let repo2 = Repo::new("https://example.com");
        assert_eq!(repo.id, repo2.id);
    }
}
