//! Operating system detection and information

use anyhow::Result;
use std::collections::HashMap;
use std::fs;

/// Operating system type
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OsType {
    Linux,
    MacOS,
    Windows,
    FreeBSD,
    Android,
    Unknown,
}

impl OsType {
    pub fn as_str(&self) -> &'static str {
        match self {
            OsType::Linux => "linux",
            OsType::MacOS => "macos",
            OsType::Windows => "windows",
            OsType::FreeBSD => "freebsd",
            OsType::Android => "android",
            OsType::Unknown => "unknown",
        }
    }
}

impl std::fmt::Display for OsType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Detailed OS information
#[derive(Debug, Clone)]
pub struct OsInfo {
    /// OS type
    pub os_type: OsType,
    /// Distribution ID (e.g., "ubuntu", "fedora", "arch")
    pub id: String,
    /// Distribution name (e.g., "Ubuntu")
    pub name: String,
    /// Version string
    pub version: String,
    /// ID_LIKE from os-release (parent distros)
    pub id_like: Vec<String>,
    /// Pretty name for display
    pub pretty_name: String,
}

impl Default for OsInfo {
    fn default() -> Self {
        Self {
            os_type: OsType::Unknown,
            id: String::new(),
            name: String::new(),
            version: String::new(),
            id_like: Vec::new(),
            pretty_name: String::new(),
        }
    }
}

impl OsInfo {
    /// Check if distro is Debian-based
    pub fn is_debian_based(&self) -> bool {
        self.id == "debian" || self.id_like.contains(&"debian".to_string()) || self.id == "ubuntu"
    }

    /// Check if distro is Arch-based
    pub fn is_arch_based(&self) -> bool {
        self.id == "arch" || self.id_like.contains(&"arch".to_string())
    }

    /// Check if distro is Fedora/RHEL-based
    pub fn is_fedora_based(&self) -> bool {
        self.id == "fedora"
            || self.id == "rhel"
            || self.id_like.contains(&"fedora".to_string())
            || self.id_like.contains(&"rhel".to_string())
    }

    /// Check if distro is openSUSE/SUSE-based
    pub fn is_suse_based(&self) -> bool {
        self.id == "opensuse"
            || self.id == "sles"
            || self.id_like.contains(&"suse".to_string())
            || self.id_like.contains(&"opensuse".to_string())
    }

    /// Check if running in Termux (Android)
    pub fn is_termux(&self) -> bool {
        self.id == "android" || std::env::var("TERMUX_VERSION").is_ok()
    }

    /// Check if Clear Linux
    pub fn is_clear_linux(&self) -> bool {
        self.id == "clear-linux-os" || self.id_like.contains(&"clear-linux-os".to_string())
    }
}

/// Get current OS information
pub fn get_os_info() -> OsInfo {
    let os_type = get_os_type();

    match os_type {
        OsType::Linux | OsType::Android => parse_os_release().unwrap_or_else(|_| OsInfo {
            os_type,
            id: os_type.as_str().to_string(),
            ..Default::default()
        }),
        OsType::MacOS => OsInfo {
            os_type: OsType::MacOS,
            id: "macos".to_string(),
            name: "macOS".to_string(),
            pretty_name: get_macos_version().unwrap_or_else(|| "macOS".to_string()),
            ..Default::default()
        },
        OsType::Windows => OsInfo {
            os_type: OsType::Windows,
            id: "windows".to_string(),
            name: "Windows".to_string(),
            pretty_name: get_windows_version().unwrap_or_else(|| "Windows".to_string()),
            ..Default::default()
        },
        _ => OsInfo {
            os_type,
            ..Default::default()
        },
    }
}

/// Get basic OS type from compile-time detection
fn get_os_type() -> OsType {
    #[cfg(target_os = "linux")]
    {
        // Check for Android/Termux
        if std::env::var("TERMUX_VERSION").is_ok() || std::env::var("ANDROID_ROOT").is_ok() {
            return OsType::Android;
        }
        OsType::Linux
    }

    #[cfg(target_os = "macos")]
    {
        OsType::MacOS
    }

    #[cfg(target_os = "windows")]
    {
        OsType::Windows
    }

    #[cfg(target_os = "freebsd")]
    {
        OsType::FreeBSD
    }

    #[cfg(target_os = "android")]
    {
        OsType::Android
    }

    #[cfg(not(any(
        target_os = "linux",
        target_os = "macos",
        target_os = "windows",
        target_os = "freebsd",
        target_os = "android"
    )))]
    {
        OsType::Unknown
    }
}

/// Parse /etc/os-release file
fn parse_os_release() -> Result<OsInfo> {
    let content = fs::read_to_string("/etc/os-release")?;
    let mut fields: HashMap<String, String> = HashMap::new();

    for line in content.lines() {
        if let Some((key, value)) = line.split_once('=') {
            let value = value.trim_matches('"').to_string();
            fields.insert(key.to_string(), value);
        }
    }

    let id = fields.get("ID").cloned().unwrap_or_default();
    let id_like: Vec<String> = fields
        .get("ID_LIKE")
        .map(|s| s.split_whitespace().map(String::from).collect())
        .unwrap_or_default();

    // Detect Android
    let os_type = if id == "android" || std::env::var("TERMUX_VERSION").is_ok() {
        OsType::Android
    } else {
        OsType::Linux
    };

    Ok(OsInfo {
        os_type,
        id,
        name: fields.get("NAME").cloned().unwrap_or_default(),
        version: fields.get("VERSION_ID").cloned().unwrap_or_default(),
        id_like,
        pretty_name: fields.get("PRETTY_NAME").cloned().unwrap_or_default(),
    })
}

/// Get macOS version string
fn get_macos_version() -> Option<String> {
    std::process::Command::new("sw_vers")
        .arg("-productVersion")
        .output()
        .ok()
        .and_then(|output| {
            if output.status.success() {
                Some(format!(
                    "macOS {}",
                    String::from_utf8_lossy(&output.stdout).trim()
                ))
            } else {
                None
            }
        })
}

/// Get Windows version string
fn get_windows_version() -> Option<String> {
    #[cfg(windows)]
    {
        // Use winapi to get version
        Some("Windows".to_string())
    }

    #[cfg(not(windows))]
    {
        None
    }
}

/// Get a specific value from os-release
pub fn os_release(key: &str) -> Option<String> {
    fs::read_to_string("/etc/os-release")
        .ok()
        .and_then(|content| {
            for line in content.lines() {
                if let Some((k, v)) = line.split_once('=') {
                    if k == key {
                        return Some(v.trim_matches('"').to_string());
                    }
                }
            }
            None
        })
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_os_info() {
        let info = get_os_info();
        // Should return a valid OS type
        assert_ne!(info.os_type, OsType::Unknown);
    }

    #[test]
    fn test_os_type_display() {
        assert_eq!(OsType::Linux.to_string(), "linux");
        assert_eq!(OsType::MacOS.to_string(), "macos");
        assert_eq!(OsType::Windows.to_string(), "windows");
    }

    #[test]
    #[cfg(target_os = "linux")]
    fn test_parse_os_release() {
        let info = parse_os_release();
        // Should succeed on Linux with /etc/os-release
        assert!(info.is_ok() || !std::path::Path::new("/etc/os-release").exists());
    }
}
