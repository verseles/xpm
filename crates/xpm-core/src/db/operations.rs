//! Database operations for XPM

use crate::os::dirs::XpmDirs;
use anyhow::{Context, Result};
use chrono::{Duration, Utc};
use native_db::*;
use once_cell::sync::Lazy;
use parking_lot::RwLock;
use serde::{de::DeserializeOwned, Serialize};
use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::OnceLock;

use super::models::{Package, PackageKey, Repo, RepoKey, Setting, SettingKey};

/// Static models definition - must live for 'static
static MODELS: Lazy<Models> = Lazy::new(|| {
    let mut models = Models::new();
    models
        .define::<Package>()
        .expect("Failed to define Package model");
    models
        .define::<Repo>()
        .expect("Failed to define Repo model");
    models
        .define::<Setting>()
        .expect("Failed to define Setting model");
    models
});

/// Global database instance
static DB_INSTANCE: OnceLock<Database> = OnceLock::new();

/// Database wrapper for XPM
pub struct Database {
    db: native_db::Database<'static>,
    /// In-memory cache for settings
    settings_cache: RwLock<HashMap<String, String>>,
}

impl Database {
    /// Initialize or get the global database instance
    pub fn instance() -> Result<&'static Database> {
        if let Some(db) = DB_INSTANCE.get() {
            return Ok(db);
        }

        let db = Self::new()?;
        Ok(DB_INSTANCE.get_or_init(|| db))
    }

    /// Create a new database instance
    fn new() -> Result<Self> {
        let db_path = Self::db_path()?;

        // Ensure parent directory exists
        if let Some(parent) = db_path.parent() {
            std::fs::create_dir_all(parent).context("Failed to create database directory")?;
        }

        // Create database using static models
        let db = Builder::new()
            .create(&MODELS, &db_path)
            .context("Failed to create database")?;

        Ok(Self {
            db,
            settings_cache: RwLock::new(HashMap::new()),
        })
    }

    /// Get database file path
    fn db_path() -> Result<PathBuf> {
        let data_dir = XpmDirs::data_dir()?;
        Ok(data_dir.join("db").join("xpm.redb"))
    }

    // ==================== Package Operations ====================

    /// Get all packages
    pub fn get_all_packages(&self) -> Result<Vec<Package>> {
        let r = self.db.r_transaction()?;
        let packages: Vec<Package> = r.scan().primary()?.all()?.filter_map(|p| p.ok()).collect();
        Ok(packages)
    }

    /// Get packages with a limit
    pub fn get_packages_limited(&self, limit: usize) -> Result<Vec<Package>> {
        let r = self.db.r_transaction()?;
        let packages: Vec<Package> = r
            .scan()
            .primary()?
            .all()?
            .filter_map(|p| p.ok())
            .take(limit)
            .collect();
        Ok(packages)
    }

    /// Find package by name
    pub fn find_package_by_name(&self, name: &str) -> Result<Option<Package>> {
        let r = self.db.r_transaction()?;
        let pkg = r.get().secondary(PackageKey::name, name.to_string())?;
        Ok(pkg)
    }

    /// Search packages by term (searches name, desc, title)
    pub fn search_packages(&self, terms: &[String], limit: usize) -> Result<Vec<Package>> {
        let r = self.db.r_transaction()?;
        let terms_lower: Vec<String> = terms.iter().map(|t| t.to_lowercase()).collect();

        let mut results: Vec<Package> = r
            .scan()
            .primary()?
            .all()?
            .filter_map(|p| p.ok())
            .filter(|pkg: &Package| {
                terms_lower.iter().any(|term| {
                    pkg.name.to_lowercase().contains(term)
                        || pkg
                            .desc
                            .as_ref()
                            .map(|d| d.to_lowercase().contains(term))
                            .unwrap_or(false)
                        || pkg
                            .title
                            .as_ref()
                            .map(|t| t.to_lowercase().contains(term))
                            .unwrap_or(false)
                })
            })
            .take(limit)
            .collect();

        // Sort by name
        results.sort_by(|a, b| a.name.cmp(&b.name));
        Ok(results)
    }

    /// Get installed packages
    pub fn get_installed_packages(&self) -> Result<Vec<Package>> {
        let r = self.db.r_transaction()?;
        let installed: Vec<Package> = r
            .scan()
            .primary()?
            .all()?
            .filter_map(|p| p.ok())
            .filter(|pkg: &Package| pkg.is_installed())
            .collect();

        Ok(installed)
    }

    /// Insert or update a package
    pub fn upsert_package(&self, package: Package) -> Result<Package> {
        let rw = self.db.rw_transaction()?;

        // Check if package exists
        let existing: Option<Package> =
            rw.get().secondary(PackageKey::name, package.name.clone())?;

        if let Some(existing) = existing {
            let mut updated = package;
            updated.id = existing.id;
            rw.update(existing, updated.clone())?;
            rw.commit()?;
            Ok(updated)
        } else {
            rw.insert(package.clone())?;
            rw.commit()?;
            // Get the inserted package with ID
            let r = self.db.r_transaction()?;
            let inserted: Option<Package> =
                r.get().secondary(PackageKey::name, package.name.clone())?;
            Ok(inserted.unwrap_or(package))
        }
    }

    /// Delete packages that are not installed
    pub fn delete_uninstalled_packages(&self) -> Result<usize> {
        let rw = self.db.rw_transaction()?;
        let uninstalled_packages: Vec<Package> = rw
            .scan()
            .primary()?
            .all()?
            .filter_map(|p| p.ok())
            .filter(|pkg: &Package| !pkg.is_installed())
            .collect();

        let mut deleted = 0;
        for pkg in uninstalled_packages {
            rw.remove(pkg)?;
            deleted += 1;
        }

        rw.commit()?;
        Ok(deleted)
    }

    // ==================== Repo Operations ====================

    /// Get all repositories
    pub fn get_all_repos(&self) -> Result<Vec<Repo>> {
        let r = self.db.r_transaction()?;
        let repos: Vec<Repo> = r.scan().primary()?.all()?.filter_map(|p| p.ok()).collect();
        Ok(repos)
    }

    /// Find repo by URL
    pub fn find_repo_by_url(&self, url: &str) -> Result<Option<Repo>> {
        let r = self.db.r_transaction()?;
        let repo = r.get().secondary(RepoKey::url, url.to_string())?;
        Ok(repo)
    }

    /// Insert or update a repository
    pub fn upsert_repo(&self, repo: Repo) -> Result<Repo> {
        let rw = self.db.rw_transaction()?;

        let existing: Option<Repo> = rw.get().secondary(RepoKey::url, repo.url.clone())?;

        if let Some(existing) = existing {
            let mut updated = repo;
            updated.id = existing.id;
            rw.update(existing, updated.clone())?;
            rw.commit()?;
            Ok(updated)
        } else {
            rw.insert(repo.clone())?;
            rw.commit()?;
            let r = self.db.r_transaction()?;
            let inserted: Option<Repo> = r.get().secondary(RepoKey::url, repo.url.clone())?;
            Ok(inserted.unwrap_or(repo))
        }
    }

    /// Delete a repository by URL
    pub fn delete_repo(&self, url: &str) -> Result<bool> {
        let rw = self.db.rw_transaction()?;

        let repo: Option<Repo> = rw.get().secondary(RepoKey::url, url.to_string())?;

        if let Some(repo) = repo {
            rw.remove(repo)?;
            rw.commit()?;
            Ok(true)
        } else {
            Ok(false)
        }
    }

    // ==================== Settings Operations ====================

    /// Get a setting value
    pub fn get_setting<T: DeserializeOwned>(&self, key: &str) -> Result<Option<T>> {
        let key_lower = key.to_lowercase();

        // Check cache first
        {
            let cache = self.settings_cache.read();
            if let Some(value) = cache.get(&key_lower) {
                let parsed: T = serde_json::from_str(value)?;
                return Ok(Some(parsed));
            }
        }

        // Query database
        let r = self.db.r_transaction()?;
        let setting: Option<Setting> = r.get().secondary(SettingKey::key, key_lower.clone())?;

        if let Some(setting) = setting {
            // Check if expired
            if setting.is_expired() {
                return Ok(None);
            }

            // Update cache
            {
                let mut cache = self.settings_cache.write();
                cache.insert(key_lower, setting.value.clone());
            }

            let parsed: T = serde_json::from_str(&setting.value)?;
            Ok(Some(parsed))
        } else {
            Ok(None)
        }
    }

    /// Get a setting with default value
    pub fn get_setting_or<T: DeserializeOwned>(&self, key: &str, default: T) -> Result<T> {
        match self.get_setting(key)? {
            Some(value) => Ok(value),
            None => Ok(default),
        }
    }

    /// Set a setting value
    pub fn set_setting<T: Serialize>(&self, key: &str, value: &T) -> Result<()> {
        self.set_setting_with_expiry(key, value, None)
    }

    /// Set a setting with expiration
    pub fn set_setting_with_expiry<T: Serialize>(
        &self,
        key: &str,
        value: &T,
        expires_in: Option<Duration>,
    ) -> Result<()> {
        let key_lower = key.to_lowercase();
        let value_json = serde_json::to_string(value)?;
        let expires_at = expires_in.map(|d| Utc::now() + d);

        let rw = self.db.rw_transaction()?;

        // Remove existing if present
        let existing: Option<Setting> = rw.get().secondary(SettingKey::key, key_lower.clone())?;
        if let Some(existing) = existing {
            rw.remove(existing)?;
        }

        let setting = match expires_at {
            Some(exp) => Setting::with_expiry(key_lower.clone(), value_json.clone(), exp),
            None => Setting::new(key_lower.clone(), value_json.clone()),
        };
        rw.insert(setting)?;
        rw.commit()?;

        // Update cache
        {
            let mut cache = self.settings_cache.write();
            cache.insert(key_lower, value_json);
        }

        Ok(())
    }

    /// Delete a setting
    pub fn delete_setting(&self, key: &str) -> Result<bool> {
        let key_lower = key.to_lowercase();

        // Remove from cache
        {
            let mut cache = self.settings_cache.write();
            cache.remove(&key_lower);
        }

        let rw = self.db.rw_transaction()?;
        let setting: Option<Setting> = rw.get().secondary(SettingKey::key, key_lower)?;

        if let Some(setting) = setting {
            rw.remove(setting)?;
            rw.commit()?;
            Ok(true)
        } else {
            Ok(false)
        }
    }

    /// Delete all expired settings
    pub fn delete_expired_settings(&self) -> Result<usize> {
        let rw = self.db.rw_transaction()?;
        let expired_settings: Vec<Setting> = rw
            .scan()
            .primary()?
            .all()?
            .filter_map(|p| p.ok())
            .filter(|s: &Setting| s.is_expired())
            .collect();

        let mut deleted = 0;
        for setting in expired_settings {
            // Remove from cache
            {
                let mut cache = self.settings_cache.write();
                cache.remove(&setting.key);
            }
            rw.remove(setting)?;
            deleted += 1;
        }

        rw.commit()?;
        Ok(deleted)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    fn create_test_db() -> Result<native_db::Database<'static>> {
        let temp_dir = TempDir::new()?;
        let db_path = temp_dir.path().join("test.redb");

        // Leak the temp_dir to keep it alive
        std::mem::forget(temp_dir);

        let db = Builder::new().create(&*MODELS, &db_path)?;
        Ok(db)
    }

    #[test]
    fn test_models_defined() {
        // Just verify models can be accessed
        let _ = &*MODELS;
    }

    #[test]
    fn test_search_packages() -> Result<()> {
        let db_instance = create_test_db()?;
        let db = Database {
            db: db_instance,
            settings_cache: RwLock::new(HashMap::new()),
        };

        // Insert some packages
        let p1 = Package {
            name: "vim".to_string(),
            desc: Some("Vi Improved".to_string()),
            ..Package::new("vim")
        };
        db.upsert_package(p1)?;

        let p2 = Package {
            name: "neovim".to_string(),
            desc: Some("Hyperextensible Vim-based text editor".to_string()),
            ..Package::new("neovim")
        };
        db.upsert_package(p2)?;

        let p3 = Package {
            name: "emacs".to_string(),
            desc: Some("GNU Emacs text editor".to_string()),
            ..Package::new("emacs")
        };
        db.upsert_package(p3)?;

        // Search for "vim"
        let results = db.search_packages(&["vim".to_string()], 10)?;
        assert_eq!(results.len(), 2);
        assert_eq!(results[0].name, "neovim");
        assert_eq!(results[1].name, "vim");

        // Search for "text editor"
        let results = db.search_packages(&["text".to_string(), "editor".to_string()], 10)?;
        assert_eq!(results.len(), 2); // neovim and emacs
        assert!(results.iter().any(|p| p.name == "neovim"));
        assert!(results.iter().any(|p| p.name == "emacs"));

        Ok(())
    }
}
