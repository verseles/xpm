import 'package:xpm/native_is_for_everyone/models/native_package.dart';

abstract class NativePackageManager {
  Future<List<NativePackage>> search(String name, {int? limit});
  Future<void> install(String name);
  Future<bool> isInstalled(String name);
  Future<NativePackage?> get(String name);
}
