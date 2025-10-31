import 'package:xpm/native_is_for_everyone/distro_managers/apt.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

class NativePackageManagerDetector {
  static Future<NativePackageManager?> detect() async {
    if (await Executable('apt').find() != null) {
      return AptPackageManager();
    }
    // Add other package managers here
    return null;
  }
}
