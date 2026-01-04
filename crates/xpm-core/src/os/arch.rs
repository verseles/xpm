//! CPU Architecture detection

use std::process::Command;

/// Supported CPU architectures
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Architecture {
    X86_64,
    X86,
    Aarch64,
    Arm,
    Ppc64,
    Ppc64Le,
    S390x,
    Riscv64,
    Unknown,
}

impl Architecture {
    /// Get architecture string for display
    pub fn as_str(&self) -> &'static str {
        match self {
            Architecture::X86_64 => "x86_64",
            Architecture::X86 => "x86",
            Architecture::Aarch64 => "aarch64",
            Architecture::Arm => "arm",
            Architecture::Ppc64 => "ppc64",
            Architecture::Ppc64Le => "ppc64le",
            Architecture::S390x => "s390x",
            Architecture::Riscv64 => "riscv64",
            Architecture::Unknown => "unknown",
        }
    }

    /// Parse architecture from string
    pub fn parse(s: &str) -> Self {
        match s.to_lowercase().as_str() {
            "x86_64" | "amd64" | "x64" => Architecture::X86_64,
            "x86" | "i386" | "i486" | "i586" | "i686" => Architecture::X86,
            "aarch64" | "arm64" => Architecture::Aarch64,
            "arm" | "armv7" | "armv7l" | "armhf" => Architecture::Arm,
            "ppc64" | "powerpc64" => Architecture::Ppc64,
            "ppc64le" | "powerpc64le" => Architecture::Ppc64Le,
            "s390x" => Architecture::S390x,
            "riscv64" | "riscv64gc" => Architecture::Riscv64,
            _ => Architecture::Unknown,
        }
    }
}

impl std::fmt::Display for Architecture {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.as_str())
    }
}

/// Get current system architecture
pub fn get_architecture() -> Architecture {
    // First try compile-time detection
    #[cfg(target_arch = "x86_64")]
    return Architecture::X86_64;

    #[cfg(target_arch = "x86")]
    return Architecture::X86;

    #[cfg(target_arch = "aarch64")]
    return Architecture::Aarch64;

    #[cfg(target_arch = "arm")]
    return Architecture::Arm;

    #[cfg(target_arch = "powerpc64")]
    return Architecture::Ppc64;

    #[cfg(target_arch = "s390x")]
    return Architecture::S390x;

    #[cfg(target_arch = "riscv64")]
    return Architecture::Riscv64;

    // Fallback to runtime detection
    #[cfg(not(any(
        target_arch = "x86_64",
        target_arch = "x86",
        target_arch = "aarch64",
        target_arch = "arm",
        target_arch = "powerpc64",
        target_arch = "s390x",
        target_arch = "riscv64"
    )))]
    {
        detect_architecture_runtime()
    }
}

/// Runtime architecture detection using uname
#[allow(dead_code)]
fn detect_architecture_runtime() -> Architecture {
    if cfg!(target_os = "windows") {
        // On Windows, use PROCESSOR_ARCHITECTURE env var
        if let Ok(arch) = std::env::var("PROCESSOR_ARCHITECTURE") {
            return Architecture::parse(&arch);
        }
    } else {
        // On Unix-like systems, use uname -m
        if let Ok(output) = Command::new("uname").arg("-m").output() {
            if output.status.success() {
                let arch_str = String::from_utf8_lossy(&output.stdout);
                return Architecture::parse(arch_str.trim());
            }
        }
    }

    Architecture::Unknown
}

/// Get platform string (os-arch)
pub fn get_platform() -> String {
    let os = std::env::consts::OS;
    let arch = get_architecture();
    format!("{}-{}", os, arch)
}

/// Architecture correspondence map for legacy compatibility
pub fn normalize_arch(arch: &str) -> String {
    match arch.to_lowercase().as_str() {
        "linux64" => "linux-x86_64".to_string(),
        "linux32" => "linux-i686".to_string(),
        "linuxarm" => "linux-armv7l".to_string(),
        "linuxarm64" => "linux-aarch64".to_string(),
        "windows32" | "win32" => "windows-i686".to_string(),
        "win64" => "windows-x86_64".to_string(),
        "macos64" => "darwin-x86_64".to_string(),
        "macos-aarch64" | "macos-arm64" => "darwin-aarch64".to_string(),
        "freebsd32" => "freebsd-i686".to_string(),
        "freebsd64" => "freebsd-x86_64".to_string(),
        other => other.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_arch_from_str() {
        assert_eq!(Architecture::parse("x86_64"), Architecture::X86_64);
        assert_eq!(Architecture::parse("amd64"), Architecture::X86_64);
        assert_eq!(Architecture::parse("aarch64"), Architecture::Aarch64);
        assert_eq!(Architecture::parse("arm64"), Architecture::Aarch64);
        assert_eq!(Architecture::parse("unknown"), Architecture::Unknown);
    }

    #[test]
    fn test_arch_display() {
        assert_eq!(Architecture::X86_64.to_string(), "x86_64");
        assert_eq!(Architecture::Aarch64.to_string(), "aarch64");
    }

    #[test]
    fn test_get_architecture() {
        let arch = get_architecture();
        // Should return a valid architecture on any supported platform
        assert_ne!(arch, Architecture::Unknown);
    }

    #[test]
    fn test_normalize_arch() {
        assert_eq!(normalize_arch("linux64"), "linux-x86_64".to_string());
        assert_eq!(normalize_arch("win64"), "windows-x86_64".to_string());
        assert_eq!(normalize_arch("custom"), "custom".to_string());
    }
}
