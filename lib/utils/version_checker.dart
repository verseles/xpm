import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:xpm/utils/logger.dart';

/// Enum representing the different types of version updates.
enum Types { major, minor, patch }

/// A class to check for new versions of a package.
class VersionChecker {
  final Dio _dio = Dio();

  /// Returns the latest version of the given package.
  ///
  /// [packageName] is the name of the package to check for updates.
  Future<Version> getLatestVersion(String packageName) async {
    final baseEndpoint = 'https://pub.dev/api/packages';
    final response = await _dio.get('$baseEndpoint/$packageName');
    try {
      if (response.statusCode == 200) {
        return Version.parse(response.data['latest']['version']);
      } else {
        Logger.error('Error: ${response.statusCode}');
        exit(generalError);
      }
    } catch (e) {
      Logger.error(e.toString());
      exit(generalError);
    }
  }

  /// Checks for a new version of the given package and returns the new version if available.
  ///
  /// [packageName] is the name of the package to check for updates.
  /// [currentVersion] is the current version of the package.
  /// [type] is the type of update to check for (major, minor, or patch). Defaults to minor.
  Future<Version?> checkForNewVersion(
      String packageName, Version currentVersion,
      {Types type = Types.minor, Version? newVersion}) async {
    newVersion ??= await getLatestVersion(packageName);
    final hasUpdate = compareVersions(currentVersion, newVersion, type);
    return hasUpdate;
  }

  /// Compares two versions and returns the newer version if it meets the specified update type criteria.
  ///
  /// [current] is the current version of the package.
  /// [newer] is the newer version of the package.
  /// [type] is the type of update to check for (major, minor, or patch).
  Version? compareVersions(Version current, Version newer, Types type) {
    switch (type) {
      case Types.major:
        if (current.major < newer.major) {
          return newer;
        }
        break;
      case Types.minor:
        if (current.minor < newer.minor && current.major >= newer.major) {
          return newer;
        }
        break;
      case Types.patch:
        if (current.patch < newer.patch &&
            current.minor >= newer.minor &&
            current.major >= newer.major) {
          return newer;
        }
        break;
    }

    return null;
  }
}
