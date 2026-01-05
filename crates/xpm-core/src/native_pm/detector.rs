use super::{
    AptPackageManager, BrewPackageManager, ChocoPackageManager, DnfPackageManager,
    FlatpakPackageManager, NativePM, PacmanPackageManager, ScoopPackageManager, SnapPackageManager,
    SwupdPackageManager, TermuxPackageManager, ZypperPackageManager,
};
use crate::os::{executable::Executable, os_info::get_os_info};

pub async fn detect_native_pm() -> Option<NativePM> {
    let os_info = get_os_info();

    if os_info.is_android() && Executable::new("pkg").exists() {
        return Some(NativePM::Termux(TermuxPackageManager::new().await));
    }

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

    if os_info.is_windows() {
        if Executable::new("scoop").exists() {
            return Some(NativePM::Scoop(ScoopPackageManager::new().await));
        }
        if Executable::new("choco").exists() {
            return Some(NativePM::Choco(ChocoPackageManager::new().await));
        }
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
pub fn has_snap() -> bool {
    Executable::new("snap").exists()
}

#[allow(dead_code)]
pub fn has_flatpak() -> bool {
    Executable::new("flatpak").exists()
}

#[allow(dead_code)]
pub async fn get_snap_pm() -> Option<NativePM> {
    if has_snap() {
        Some(NativePM::Snap(SnapPackageManager::new().await))
    } else {
        None
    }
}

#[allow(dead_code)]
pub async fn get_flatpak_pm() -> Option<NativePM> {
    if has_flatpak() {
        Some(NativePM::Flatpak(FlatpakPackageManager::new().await))
    } else {
        None
    }
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
        || Executable::new("pkg").exists()
        || Executable::new("choco").exists()
        || Executable::new("scoop").exists()
}
