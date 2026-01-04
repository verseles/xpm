//! Native package manager detection

use super::{AptPackageManager, NativePM, PacmanPackageManager};
use crate::os::{executable::Executable, os_info::get_os_info};

/// Detect the native package manager for the current system
pub async fn detect_native_pm() -> Option<NativePM> {
    let os_info = get_os_info();

    // Check for Arch Linux (pacman/paru/yay)
    if os_info.is_arch_based() {
        // Try AUR helpers first
        if Executable::new("paru").exists()
            || Executable::new("yay").exists()
            || Executable::new("pacman").exists()
        {
            return Some(NativePM::Pacman(PacmanPackageManager::new().await));
        }
    }

    // Check for Debian/Ubuntu (apt)
    if os_info.is_debian_based()
        && (Executable::new("apt").exists() || Executable::new("apt-get").exists())
    {
        return Some(NativePM::Apt(AptPackageManager::new().await));
    }

    // Fallback: try to detect by available commands
    if Executable::new("pacman").exists() {
        return Some(NativePM::Pacman(PacmanPackageManager::new().await));
    }

    if Executable::new("apt").exists() {
        return Some(NativePM::Apt(AptPackageManager::new().await));
    }

    None
}

/// Check if any native package manager is available
#[allow(dead_code)]
pub fn has_native_pm() -> bool {
    Executable::new("apt").exists()
        || Executable::new("apt-get").exists()
        || Executable::new("pacman").exists()
        || Executable::new("paru").exists()
        || Executable::new("yay").exists()
}
