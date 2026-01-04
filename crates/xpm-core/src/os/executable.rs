//! Executable detection and PATH lookup

use once_cell::sync::Lazy;
use parking_lot::RwLock;
use std::collections::HashMap;
use std::path::PathBuf;
use std::process::Command;

/// Cache for executable lookups
static EXEC_CACHE: Lazy<RwLock<HashMap<String, Option<PathBuf>>>> =
    Lazy::new(|| RwLock::new(HashMap::new()));

/// Executable finder utility
#[derive(Debug, Clone)]
pub struct Executable {
    name: String,
}

impl Executable {
    /// Create a new Executable finder
    pub fn new(name: impl Into<String>) -> Self {
        Self { name: name.into() }
    }

    /// Check if executable exists in PATH
    pub fn exists(&self) -> bool {
        self.find().is_some()
    }

    /// Check if executable exists (async version)
    pub async fn exists_async(&self) -> bool {
        self.find_async().await.is_some()
    }

    /// Find executable path, using cache
    pub fn find(&self) -> Option<PathBuf> {
        self.find_internal(true)
    }

    /// Find executable path, optionally using cache
    pub fn find_with_cache(&self, use_cache: bool) -> Option<PathBuf> {
        self.find_internal(use_cache)
    }

    /// Async version of find
    pub async fn find_async(&self) -> Option<PathBuf> {
        // For now, just call sync version since `which` is fast
        self.find()
    }

    /// Internal find implementation
    fn find_internal(&self, use_cache: bool) -> Option<PathBuf> {
        // Check cache first
        if use_cache {
            let cache = EXEC_CACHE.read();
            if let Some(cached) = cache.get(&self.name) {
                return cached.clone();
            }
        }

        // Perform lookup
        let result = self.which();

        // Update cache
        {
            let mut cache = EXEC_CACHE.write();
            cache.insert(self.name.clone(), result.clone());
        }

        result
    }

    /// Use `which` command to find executable
    fn which(&self) -> Option<PathBuf> {
        #[cfg(windows)]
        let which_cmd = "where";
        #[cfg(not(windows))]
        let which_cmd = "which";

        Command::new(which_cmd)
            .arg(&self.name)
            .output()
            .ok()
            .and_then(|output| {
                if output.status.success() {
                    let path_str = String::from_utf8_lossy(&output.stdout);
                    let path = path_str.lines().next()?.trim();
                    if !path.is_empty() {
                        Some(PathBuf::from(path))
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
    }

    /// Find executable in specific directories
    pub fn find_in(&self, dirs: &[PathBuf]) -> Option<PathBuf> {
        for dir in dirs {
            let path = dir.join(&self.name);
            if path.exists() && path.is_file() {
                #[cfg(unix)]
                {
                    use std::os::unix::fs::PermissionsExt;
                    if let Ok(metadata) = path.metadata() {
                        if metadata.permissions().mode() & 0o111 != 0 {
                            return Some(path);
                        }
                    }
                }
                #[cfg(not(unix))]
                {
                    return Some(path);
                }
            }

            // Try with common extensions on Windows
            #[cfg(windows)]
            {
                for ext in &[".exe", ".cmd", ".bat", ".com"] {
                    let path_with_ext = dir.join(format!("{}{}", &self.name, ext));
                    if path_with_ext.exists() && path_with_ext.is_file() {
                        return Some(path_with_ext);
                    }
                }
            }
        }
        None
    }

    /// Clear the executable cache
    pub fn clear_cache() {
        let mut cache = EXEC_CACHE.write();
        cache.clear();
    }

    /// Remove a specific entry from cache
    pub fn invalidate_cache(name: &str) {
        let mut cache = EXEC_CACHE.write();
        cache.remove(name);
    }
}

/// Find multiple executables, returning the first one found
pub fn find_first(names: &[&str]) -> Option<(String, PathBuf)> {
    for name in names {
        let exec = Executable::new(*name);
        if let Some(path) = exec.find() {
            return Some((name.to_string(), path));
        }
    }
    None
}

/// Check if any of the executables exist
pub fn any_exists(names: &[&str]) -> bool {
    names.iter().any(|name| Executable::new(*name).exists())
}

/// Get paths from PATH environment variable
pub fn get_path_dirs() -> Vec<PathBuf> {
    std::env::var("PATH")
        .unwrap_or_default()
        .split(if cfg!(windows) { ';' } else { ':' })
        .map(PathBuf::from)
        .filter(|p| p.exists())
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_find_common_executable() {
        // These should exist on most Unix systems
        #[cfg(unix)]
        {
            let sh = Executable::new("sh");
            assert!(sh.exists());

            let path = sh.find();
            assert!(path.is_some());
        }

        // These should exist on Windows
        #[cfg(windows)]
        {
            let cmd = Executable::new("cmd");
            assert!(cmd.exists());
        }
    }

    #[test]
    fn test_nonexistent_executable() {
        let fake = Executable::new("this_executable_should_not_exist_12345");
        assert!(!fake.exists());
        assert!(fake.find().is_none());
    }

    #[test]
    fn test_cache() {
        let name = "test_cache_exec";
        Executable::clear_cache();

        // First call populates cache
        let exec = Executable::new(name);
        let _ = exec.find();

        // Check cache has entry
        {
            let cache = EXEC_CACHE.read();
            assert!(cache.contains_key(name));
        }

        // Clear and verify
        Executable::clear_cache();
        {
            let cache = EXEC_CACHE.read();
            assert!(!cache.contains_key(name));
        }
    }

    #[test]
    fn test_find_first() {
        #[cfg(unix)]
        {
            let result = find_first(&["nonexistent123", "sh", "bash"]);
            assert!(result.is_some());
            let (name, _path) = result.unwrap();
            assert_eq!(name, "sh");
        }
    }

    #[test]
    fn test_get_path_dirs() {
        let dirs = get_path_dirs();
        assert!(!dirs.is_empty());
    }
}
