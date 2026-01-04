//! Bash script parsing module

use anyhow::Result;
use once_cell::sync::OnceCell;
use regex::Regex;
use std::fs;
use std::path::{Path, PathBuf};

/// Bash script parser for XPM package scripts
#[derive(Debug)]
pub struct BashScript {
    path: PathBuf,
    content: OnceCell<Option<String>>,
}

impl BashScript {
    /// Create a new BashScript from path
    pub fn new(path: impl Into<PathBuf>) -> Self {
        Self {
            path: path.into(),
            content: OnceCell::new(),
        }
    }

    /// Check if script file exists
    pub fn exists(&self) -> bool {
        self.path.exists()
    }

    /// Get script contents (cached)
    pub fn contents(&self) -> Option<&String> {
        self.content
            .get_or_init(|| fs::read_to_string(&self.path).ok())
            .as_ref()
    }

    /// Get script contents async
    pub async fn contents_async(&self) -> Option<String> {
        if self.content.get().is_some() {
            return self.content.get()?.clone();
        }

        tokio::fs::read_to_string(&self.path).await.ok()
    }

    /// Get a readonly variable value
    /// Pattern: readonly VARNAME="value"
    pub fn get(&self, param: &str) -> Option<String> {
        let content = self.contents()?;
        let pattern = format!(r#"readonly\s+{}="([^"]*)""#, regex::escape(param));
        let re = Regex::new(&pattern).ok()?;
        re.captures(content)?.get(1).map(|m| m.as_str().to_string())
    }

    /// Get an array variable
    /// Pattern: VARNAME=(value1 value2 value3)
    pub fn get_array(&self, array_name: &str) -> Option<Vec<String>> {
        let content = self.contents()?;
        let pattern = format!(r"{}\s*=\s*\(([^)]*)\)", regex::escape(array_name));
        let re = Regex::new(&pattern).ok()?;
        let capture = re.captures(content)?.get(1)?;

        let values: Vec<String> = capture
            .as_str()
            .split_whitespace()
            .map(|s| s.trim_matches('\'').trim_matches('"').to_string())
            .filter(|s| !s.is_empty())
            .collect();

        Some(values)
    }

    /// Get the first value from xPROVIDES array
    pub fn get_first_provides(&self) -> Option<String> {
        self.get_array("xPROVIDES")?
            .into_iter()
            .next()
            .filter(|s| !s.is_empty())
    }

    /// Get all readonly variables
    pub fn variables(&self) -> Option<Vec<(String, String)>> {
        let content = self.contents()?;
        let re = Regex::new(r#"readonly\s+([a-zA-Z_][a-zA-Z0-9_]*)="([^"]*)""#).ok()?;

        let vars: Vec<(String, String)> = re
            .captures_iter(content)
            .filter_map(|cap| {
                let name = cap.get(1)?.as_str().to_string();
                let value = cap.get(2)?.as_str().to_string();
                Some((name, value))
            })
            .collect();

        Some(vars)
    }

    /// Check if script has a specific function
    /// Pattern: function_name() {
    pub fn has_function(&self, function_name: &str) -> bool {
        self.contents()
            .map(|content| {
                let pattern = format!("{}\\s*\\(\\s*\\)\\s*\\{{", regex::escape(function_name));
                Regex::new(&pattern)
                    .map(|re| re.is_match(content))
                    .unwrap_or(false)
            })
            .unwrap_or(false)
    }

    /// Get all functions in the script
    pub fn functions(&self) -> Option<Vec<String>> {
        let content = self.contents()?;
        let re = Regex::new(r"([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\s*\)\s*\{").ok()?;

        let funcs: Vec<String> = re
            .captures_iter(content)
            .filter_map(|cap| cap.get(1).map(|m| m.as_str().to_string()))
            .collect();

        Some(funcs)
    }

    /// Check which install methods are available
    pub fn available_install_methods(&self) -> Vec<String> {
        let methods = [
            "any", "apt", "pacman", "dnf", "brew", "choco", "snap",
            "flatpak", "zypper", "swupd", "termux", "appimage",
        ];

        methods
            .iter()
            .filter(|m| self.has_function(&format!("install_{}", m)))
            .map(|s| s.to_string())
            .collect()
    }

    /// Check which remove methods are available
    pub fn available_remove_methods(&self) -> Vec<String> {
        let methods = [
            "any", "apt", "pacman", "dnf", "brew", "choco", "snap",
            "flatpak", "zypper", "swupd", "termux", "appimage",
        ];

        methods
            .iter()
            .filter(|m| self.has_function(&format!("remove_{}", m)))
            .map(|s| s.to_string())
            .collect()
    }

    /// Get path to script
    pub fn path(&self) -> &Path {
        &self.path
    }
}

/// Script metadata extracted from bash script
#[derive(Debug, Clone, Default)]
pub struct ScriptMetadata {
    pub name: Option<String>,
    pub version: Option<String>,
    pub title: Option<String>,
    pub desc: Option<String>,
    pub url: Option<String>,
    pub archs: Vec<String>,
    pub provides: Vec<String>,
    pub defaults: Vec<String>,
    pub methods: Vec<String>,
}

impl ScriptMetadata {
    /// Extract metadata from a bash script
    pub fn from_script(script: &BashScript) -> Self {
        Self {
            name: script.get("xNAME"),
            version: script.get("xVERSION"),
            title: script.get("xTITLE"),
            desc: script.get("xDESC"),
            url: script.get("xURL"),
            archs: script.get_array("xARCHS").unwrap_or_default(),
            provides: script.get_array("xPROVIDES").unwrap_or_default(),
            defaults: script.get_array("xDEFAULT").unwrap_or_default(),
            methods: script.available_install_methods(),
        }
    }

    /// Load metadata from a script path
    pub fn from_path(path: impl Into<PathBuf>) -> Result<Self> {
        let script = BashScript::new(path);
        if !script.exists() {
            anyhow::bail!("Script file does not exist");
        }
        Ok(Self::from_script(&script))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    fn create_test_script() -> Result<NamedTempFile> {
        let mut file = NamedTempFile::new()?;
        writeln!(file, r#"#!/bin/bash"#)?;
        writeln!(file, r#"readonly xNAME="test-package""#)?;
        writeln!(file, r#"readonly xVERSION="1.0.0""#)?;
        writeln!(file, r#"readonly xTITLE="Test Package""#)?;
        writeln!(file, r#"readonly xDESC="A test package for XPM""#)?;
        writeln!(file, r#"xARCHS=(x86_64 aarch64)"#)?;
        writeln!(file, r#"xPROVIDES=('test-bin' 'test-cli')"#)?;
        writeln!(file, r#"xDEFAULT=(apt)"#)?;
        writeln!(file)?;
        writeln!(file, r#"install_apt() {{"#)?;
        writeln!(file, r#"    $1 install test-package"#)?;
        writeln!(file, r#"}}"#)?;
        writeln!(file)?;
        writeln!(file, r#"install_any() {{"#)?;
        writeln!(file, r#"    echo "Installing...""#)?;
        writeln!(file, r#"}}"#)?;
        writeln!(file)?;
        writeln!(file, r#"validate() {{"#)?;
        writeln!(file, r#"    which test-bin"#)?;
        writeln!(file, r#"}}"#)?;
        Ok(file)
    }

    #[test]
    fn test_get_variable() -> Result<()> {
        let file = create_test_script()?;
        let script = BashScript::new(file.path());

        assert_eq!(script.get("xNAME"), Some("test-package".to_string()));
        assert_eq!(script.get("xVERSION"), Some("1.0.0".to_string()));
        assert_eq!(script.get("xNONEXISTENT"), None);
        Ok(())
    }

    #[test]
    fn test_get_array() -> Result<()> {
        let file = create_test_script()?;
        let script = BashScript::new(file.path());

        let archs = script.get_array("xARCHS").unwrap();
        assert_eq!(archs, vec!["x86_64", "aarch64"]);

        let provides = script.get_array("xPROVIDES").unwrap();
        assert_eq!(provides, vec!["test-bin", "test-cli"]);
        Ok(())
    }

    #[test]
    fn test_has_function() -> Result<()> {
        let file = create_test_script()?;
        let script = BashScript::new(file.path());

        assert!(script.has_function("install_apt"));
        assert!(script.has_function("install_any"));
        assert!(script.has_function("validate"));
        assert!(!script.has_function("install_pacman"));
        Ok(())
    }

    #[test]
    fn test_available_methods() -> Result<()> {
        let file = create_test_script()?;
        let script = BashScript::new(file.path());

        let methods = script.available_install_methods();
        assert!(methods.contains(&"apt".to_string()));
        assert!(methods.contains(&"any".to_string()));
        assert!(!methods.contains(&"pacman".to_string()));
        Ok(())
    }

    #[test]
    fn test_script_metadata() -> Result<()> {
        let file = create_test_script()?;
        let metadata = ScriptMetadata::from_path(file.path())?;

        assert_eq!(metadata.name, Some("test-package".to_string()));
        assert_eq!(metadata.version, Some("1.0.0".to_string()));
        assert_eq!(metadata.archs, vec!["x86_64", "aarch64"]);
        Ok(())
    }
}
