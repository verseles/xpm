//! XDG-compliant directory management for XPM

use anyhow::{Context, Result};
use std::path::{Path, PathBuf};

/// XPM directory management following XDG Base Directory Specification
pub struct XpmDirs;

impl XpmDirs {
    /// Application name for directory prefixes
    const APP_NAME: &'static str = "xpm";

    /// Get the configuration directory (~/.config/xpm)
    pub fn config_dir() -> Result<PathBuf> {
        let base = dirs::config_dir().context("Could not determine config directory")?;
        let path = base.join(Self::APP_NAME);
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get the data directory (~/.local/share/xpm)
    pub fn data_dir() -> Result<PathBuf> {
        let base = dirs::data_dir().context("Could not determine data directory")?;
        let path = base.join(Self::APP_NAME);
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get the cache directory (~/.cache/xpm)
    pub fn cache_dir() -> Result<PathBuf> {
        let base = dirs::cache_dir().context("Could not determine cache directory")?;
        let path = base.join(Self::APP_NAME);
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get the repos directory (~/.local/share/xpm/repos)
    pub fn repos_dir() -> Result<PathBuf> {
        let data = Self::data_dir()?;
        let path = data.join("repos");
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get a specific repo directory
    pub fn repo_dir(repo_slug: &str) -> Result<PathBuf> {
        let repos = Self::repos_dir()?;
        let path = repos.join(repo_slug);
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get the downloads cache directory
    pub fn downloads_dir() -> Result<PathBuf> {
        let cache = Self::cache_dir()?;
        let path = cache.join("downloads");
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get the temporary directory for package operations
    pub fn temp_dir(package: Option<&str>) -> Result<PathBuf> {
        let base = std::env::temp_dir().join(Self::APP_NAME);
        let path = match package {
            Some(pkg) => base.join(pkg),
            None => base,
        };
        std::fs::create_dir_all(&path)?;
        Ok(path)
    }

    /// Get user home directory
    pub fn home_dir() -> Result<PathBuf> {
        dirs::home_dir().context("Could not determine home directory")
    }

    /// Get the bin directory (first writable directory in PATH)
    pub fn bin_dir() -> Result<PathBuf> {
        // Preferred directories in order
        let preferred = ["/usr/local/bin", "/usr/bin", "~/.local/bin"];

        // Try preferred directories first
        for dir in &preferred {
            let path = if dir.starts_with('~') {
                let home = Self::home_dir()?;
                home.join(&dir[2..])
            } else {
                PathBuf::from(dir)
            };

            if path.exists() && is_writable(&path) {
                return Ok(path);
            }
        }

        // Fallback: check PATH directories
        if let Ok(path_env) = std::env::var("PATH") {
            for dir in path_env.split(':') {
                let path = PathBuf::from(dir);
                if path.exists() && is_writable(&path) {
                    return Ok(path);
                }
            }
        }

        // Last resort: ~/.local/bin
        let local_bin = Self::home_dir()?.join(".local/bin");
        std::fs::create_dir_all(&local_bin)?;
        Ok(local_bin)
    }

    /// Get the Windows Program Files directory (Windows only)
    #[cfg(windows)]
    pub fn program_files() -> Result<PathBuf> {
        std::env::var("ProgramFiles")
            .map(PathBuf::from)
            .context("Could not determine Program Files directory")
    }

    /// Clean old cache files older than specified days
    pub fn clean_cache(days: u64) -> Result<usize> {
        let cache = Self::cache_dir()?;
        let cutoff =
            std::time::SystemTime::now() - std::time::Duration::from_secs(days * 24 * 60 * 60);

        let mut deleted = 0;
        if let Ok(entries) = std::fs::read_dir(&cache) {
            for entry in entries.flatten() {
                if let Ok(metadata) = entry.metadata() {
                    if let Ok(modified) = metadata.modified() {
                        if modified < cutoff {
                            if metadata.is_dir() {
                                let _ = std::fs::remove_dir_all(entry.path());
                            } else {
                                let _ = std::fs::remove_file(entry.path());
                            }
                            deleted += 1;
                        }
                    }
                }
            }
        }

        Ok(deleted)
    }
}

/// Check if a path is writable
fn is_writable(path: &Path) -> bool {
    #[cfg(unix)]
    {
        use std::os::unix::fs::MetadataExt;
        if let Ok(metadata) = path.metadata() {
            let mode = metadata.mode();
            let uid = unsafe { libc::getuid() };
            let gid = unsafe { libc::getgid() };

            // Check owner write
            if metadata.uid() == uid && mode & 0o200 != 0 {
                return true;
            }
            // Check group write
            if metadata.gid() == gid && mode & 0o020 != 0 {
                return true;
            }
            // Check other write
            if mode & 0o002 != 0 {
                return true;
            }
            // Root can write anywhere
            if uid == 0 {
                return true;
            }
        }
        false
    }

    #[cfg(not(unix))]
    {
        // On Windows, try to create a test file
        let test_file = path.join(".xpm_write_test");
        if std::fs::write(&test_file, "test").is_ok() {
            let _ = std::fs::remove_file(&test_file);
            true
        } else {
            false
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_config_dir() {
        let dir = XpmDirs::config_dir().unwrap();
        assert!(dir.ends_with("xpm"));
        assert!(dir.exists());
    }

    #[test]
    fn test_data_dir() {
        let dir = XpmDirs::data_dir().unwrap();
        assert!(dir.ends_with("xpm"));
        assert!(dir.exists());
    }

    #[test]
    fn test_cache_dir() {
        let dir = XpmDirs::cache_dir().unwrap();
        assert!(dir.ends_with("xpm"));
        assert!(dir.exists());
    }

    #[test]
    fn test_repos_dir() {
        let dir = XpmDirs::repos_dir().unwrap();
        assert!(dir.ends_with("repos"));
        assert!(dir.exists());
    }

    #[test]
    fn test_home_dir() {
        let dir = XpmDirs::home_dir().unwrap();
        assert!(dir.exists());
    }
}
