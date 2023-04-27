import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';

enum Types { major, minor, patch }

class VersionChecker {
  final Dio _dio = Dio();

  Future<String?> checkForNewVersion(String packageName, Version currentVersion,
      {Types type = Types.minor}) async {
    try {
      final response =
          await _dio.get('https://pub.dev/api/packages/$packageName');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.data);
        final newVersion = Version.parse(data['latest']['version']);
        final hasUpdate = compareVersions(currentVersion, newVersion, type);
        if (hasUpdate != null) {
          return hasUpdate.toString();
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  Version? compareVersions(
      Version currentVersion, Version newVersion, Types type) {
    Version? newVersion;
    switch (type) {
      case Types.major:
        currentVersion.compare(newVersion);
        newVersion = currentVersion.nextMajor;
        break;
      case Types.minor:
        newVersion = currentVersion.nextMinor;
        break;
      case Types.patch:
        newVersion = currentVersion.nextPatch;
        break;
    }
    return newVersion;
  }
}
