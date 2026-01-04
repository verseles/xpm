use super::{
    AptPackageManager, BrewPackageManager, DnfPackageManager, NativePM, PacmanPackageManager,
    SwupdPackageManager, ZypperPackageManager,
};
use crate::os::{executable::Executable, os_info::get_os_info};

pub async fn detect_native_pm() -> Option<NativePM> {
    let os_info = get_os_info();

    if os_info.is_arch_based()
        && (Executable::new("paru").exists()
            || Executable::new("yay").exists()
            || Executable::new("pacman").exists())
    {
        return Some(NativePM::Pacman(PacmanPackageManager::new().await));
    }

    if os_info.is_debian_based()
        && (Executable::new("apt").exists() || Executable::new("apt-get").exists())
    {
        return Some(NativePM::Apt(AptPackageManager::new().await));
    }

    if os_info.is_fedora_based() && Executable::new("dnf").exists() {
        return Some(NativePM::Dnf(DnfPackageManager::new().await));
    }

    if os_info.is_suse_based() && Executable::new("zypper").exists() {
        return Some(NativePM::Zypper(ZypperPackageManager::new().await));
    }

    if os_info.is_clear_linux() && Executable::new("swupd").exists() {
        return Some(NativePM::Swupd(SwupdPackageManager::new().await));
    }

    if Executable::new("brew").exists() {
        return Some(NativePM::Brew(BrewPackageManager::new().await));
    }

    if Executable::new("pacman").exists() {
        return Some(NativePM::Pacman(PacmanPackageManager::new().await));
    }

    if Executable::new("apt").exists() {
        return Some(NativePM::Apt(AptPackageManager::new().await));
    }

    if Executable::new("dnf").exists() {
        return Some(NativePM::Dnf(DnfPackageManager::new().await));
    }

    if Executable::new("zypper").exists() {
        return Some(NativePM::Zypper(ZypperPackageManager::new().await));
    }

    None
}

#[allow(dead_code)]
pub fn has_native_pm() -> bool {
    Executable::new("apt").exists()
        || Executable::new("apt-get").exists()
        || Executable::new("pacman").exists()
        || Executable::new("paru").exists()
        || Executable::new("yay").exists()
        || Executable::new("dnf").exists()
        || Executable::new("zypper").exists()
        || Executable::new("brew").exists()
        || Executable::new("swupd").exists()
}
