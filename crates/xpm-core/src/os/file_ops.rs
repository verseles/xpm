//! File operations with optional sudo support

use anyhow::{Context, Result};
use std::path::Path;
use std::process::Command;

use super::executable::Executable;

/// File operations helper
pub struct FileOps;

impl FileOps {
    /// Check if sudo is available
    pub fn has_sudo() -> bool {
        Executable::new("sudo").exists()
    }

    /// Copy a file
    pub fn copy(src: &Path, dest: &Path, sudo: bool) -> Result<()> {
        if sudo && cfg!(unix) {
            Self::run_with_sudo(&["cp", "-f"], &[src, dest])?;
        } else {
            std::fs::copy(src, dest)
                .with_context(|| format!("Failed to copy {} to {}", src.display(), dest.display()))?;
        }
        Ok(())
    }

    /// Move/rename a file
    pub fn move_file(src: &Path, dest: &Path, sudo: bool) -> Result<()> {
        if sudo && cfg!(unix) {
            Self::run_with_sudo(&["mv", "-f"], &[src, dest])?;
        } else {
            std::fs::rename(src, dest)
                .with_context(|| format!("Failed to move {} to {}", src.display(), dest.display()))?;
        }
        Ok(())
    }

    /// Delete a file or directory
    pub fn delete(path: &Path, sudo: bool, recursive: bool) -> Result<()> {
        if !path.exists() {
            return Ok(());
        }

        if sudo && cfg!(unix) {
            let mut args = vec!["rm", "-f"];
            if recursive {
                args.push("-r");
            }
            Self::run_with_sudo(&args, &[path])?;
        } else if path.is_dir() && recursive {
            std::fs::remove_dir_all(path)
                .with_context(|| format!("Failed to delete directory {}", path.display()))?;
        } else if path.is_dir() {
            std::fs::remove_dir(path)
                .with_context(|| format!("Failed to delete directory {}", path.display()))?;
        } else {
            std::fs::remove_file(path)
                .with_context(|| format!("Failed to delete file {}", path.display()))?;
        }
        Ok(())
    }

    /// Make a file executable
    #[cfg(unix)]
    pub fn make_executable(path: &Path, sudo: bool) -> Result<()> {
        use std::os::unix::fs::PermissionsExt;

        if sudo {
            Self::run_with_sudo(&["chmod", "+x"], &[path])?;
        } else {
            let metadata = std::fs::metadata(path)?;
            let mut perms = metadata.permissions();
            let mode = perms.mode() | 0o111; // Add execute permission
            perms.set_mode(mode);
            std::fs::set_permissions(path, perms)?;
        }

        Ok(())
    }

    #[cfg(not(unix))]
    pub fn make_executable(_path: &Path, _sudo: bool) -> Result<()> {
        // On Windows, executability is determined by extension
        Ok(())
    }

    /// Check if a file is executable
    #[cfg(unix)]
    pub fn is_executable(path: &Path) -> bool {
        use std::os::unix::fs::PermissionsExt;

        path.metadata()
            .map(|m| m.permissions().mode() & 0o111 != 0)
            .unwrap_or(false)
    }

    #[cfg(not(unix))]
    pub fn is_executable(path: &Path) -> bool {
        path.extension()
            .map(|ext| {
                let ext = ext.to_string_lossy().to_lowercase();
                matches!(ext.as_str(), "exe" | "cmd" | "bat" | "com")
            })
            .unwrap_or(false)
    }

    /// Create a directory
    pub fn mkdir(path: &Path, sudo: bool) -> Result<()> {
        if path.exists() {
            return Ok(());
        }

        if sudo && cfg!(unix) {
            Self::run_with_sudo(&["mkdir", "-p"], &[path])?;
        } else {
            std::fs::create_dir_all(path)
                .with_context(|| format!("Failed to create directory {}", path.display()))?;
        }
        Ok(())
    }

    /// Write content to a file
    pub fn write_file(path: &Path, content: &str, sudo: bool) -> Result<()> {
        if sudo && cfg!(unix) {
            // Use tee with sudo for writing
            let mut child = Command::new("sudo")
                .args(["tee", path.to_str().unwrap_or("")])
                .stdin(std::process::Stdio::piped())
                .stdout(std::process::Stdio::null())
                .spawn()?;

            if let Some(stdin) = child.stdin.as_mut() {
                use std::io::Write;
                stdin.write_all(content.as_bytes())?;
            }

            let status = child.wait()?;
            if !status.success() {
                anyhow::bail!("Failed to write file with sudo");
            }
        } else {
            std::fs::write(path, content)
                .with_context(|| format!("Failed to write to {}", path.display()))?;
        }
        Ok(())
    }

    /// Create a symlink
    #[cfg(unix)]
    pub fn symlink(src: &Path, dest: &Path, sudo: bool) -> Result<()> {
        if sudo {
            Self::run_with_sudo(&["ln", "-sf"], &[src, dest])?;
        } else {
            // Remove existing if present
            if dest.exists() || dest.is_symlink() {
                std::fs::remove_file(dest).ok();
            }
            std::os::unix::fs::symlink(src, dest)
                .with_context(|| format!("Failed to create symlink {} -> {}", dest.display(), src.display()))?;
        }
        Ok(())
    }

    #[cfg(not(unix))]
    pub fn symlink(src: &Path, dest: &Path, _sudo: bool) -> Result<()> {
        // On Windows, try to create a symlink (may require admin)
        if dest.exists() {
            std::fs::remove_file(dest).ok();
        }

        #[cfg(windows)]
        {
            if src.is_dir() {
                std::os::windows::fs::symlink_dir(src, dest)?;
            } else {
                std::os::windows::fs::symlink_file(src, dest)?;
            }
        }

        Ok(())
    }

    /// Check if path exists
    pub fn exists(path: &Path) -> bool {
        path.exists()
    }

    /// Touch a file (create if not exists)
    pub fn touch(path: &Path, sudo: bool) -> Result<()> {
        if sudo && cfg!(unix) {
            Self::run_with_sudo(&["touch"], &[path])?;
        } else if !path.exists() {
            std::fs::write(path, "")?;
        }
        Ok(())
    }

    /// Run a command with sudo
    #[cfg(unix)]
    fn run_with_sudo(cmd: &[&str], paths: &[&Path]) -> Result<()> {
        let mut args: Vec<&str> = cmd.to_vec();
        for path in paths {
            args.push(path.to_str().unwrap_or(""));
        }

        let status = Command::new("sudo")
            .args(&args)
            .status()
            .with_context(|| format!("Failed to run sudo {:?}", cmd))?;

        if !status.success() {
            anyhow::bail!("Command failed with exit code: {:?}", status.code());
        }

        Ok(())
    }

    #[cfg(not(unix))]
    fn run_with_sudo(_cmd: &[&str], _paths: &[&Path]) -> Result<()> {
        anyhow::bail!("sudo not supported on this platform")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_copy() -> Result<()> {
        let temp = TempDir::new()?;
        let src = temp.path().join("source.txt");
        let dest = temp.path().join("dest.txt");

        std::fs::write(&src, "test content")?;
        FileOps::copy(&src, &dest, false)?;

        assert!(dest.exists());
        assert_eq!(std::fs::read_to_string(&dest)?, "test content");
        Ok(())
    }

    #[test]
    fn test_move() -> Result<()> {
        let temp = TempDir::new()?;
        let src = temp.path().join("source.txt");
        let dest = temp.path().join("dest.txt");

        std::fs::write(&src, "test content")?;
        FileOps::move_file(&src, &dest, false)?;

        assert!(!src.exists());
        assert!(dest.exists());
        Ok(())
    }

    #[test]
    fn test_delete() -> Result<()> {
        let temp = TempDir::new()?;
        let file = temp.path().join("to_delete.txt");

        std::fs::write(&file, "test")?;
        assert!(file.exists());

        FileOps::delete(&file, false, false)?;
        assert!(!file.exists());
        Ok(())
    }

    #[test]
    #[cfg(unix)]
    fn test_make_executable() -> Result<()> {
        use std::os::unix::fs::PermissionsExt;

        let temp = TempDir::new()?;
        let file = temp.path().join("script.sh");

        std::fs::write(&file, "#!/bin/sh\necho hello")?;

        // Remove execute permission first
        let mut perms = std::fs::metadata(&file)?.permissions();
        perms.set_mode(0o644);
        std::fs::set_permissions(&file, perms)?;

        assert!(!FileOps::is_executable(&file));

        FileOps::make_executable(&file, false)?;
        assert!(FileOps::is_executable(&file));
        Ok(())
    }

    #[test]
    fn test_mkdir() -> Result<()> {
        let temp = TempDir::new()?;
        let dir = temp.path().join("new_dir").join("nested");

        FileOps::mkdir(&dir, false)?;
        assert!(dir.exists());
        assert!(dir.is_dir());
        Ok(())
    }

    #[test]
    fn test_write_file() -> Result<()> {
        let temp = TempDir::new()?;
        let file = temp.path().join("write_test.txt");

        FileOps::write_file(&file, "hello world", false)?;
        assert_eq!(std::fs::read_to_string(&file)?, "hello world");
        Ok(())
    }
}
