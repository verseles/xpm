import 'package:xpm/native/apt_package_manager.dart';
import 'package:xpm/native/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

Future<NativePackageManager?> detectNativeManager() async {
  if (await Executable('apt').exists()) {
    return AptPackageManager();
  }

  return null;
}
