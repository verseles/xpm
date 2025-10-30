import 'package:xpm/native/models/native_package.dart';

abstract class NativePackageManager {
  Future<List<NativePackage>> search(String query, {int limit = 20});
  Future<void> install(String package);
  Future<bool> isInstalled(String package);
  Future<NativePackage?> getPackageDetails(String package);
}
