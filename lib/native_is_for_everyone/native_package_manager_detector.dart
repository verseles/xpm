import 'package:xpm/native_is_for_everyone/distro_managers/apt.dart';
import 'package:xpm/native_is_for_everyone/distro_managers/pacman.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

class NativePackageManagerDetector {
  static Future<NativePackageManager?> detect() async {
    // Check for APT (Debian/Ubuntu)
    if (await Executable('apt').find() != null || await Executable('apt-get').find() != null) {
      return AptPackageManager();
    }

    // Check for Pacman (Arch Linux)
    if (await Executable('pacman').find() != null) {
      return PacmanPackageManager();
    }

    // Add other package managers here
    return null;
  }
}
