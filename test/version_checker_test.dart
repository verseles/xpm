import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:xpm/utils/version_checker.dart';

void main() {
  group('VersionChecker', () {
    late VersionChecker versionChecker;

    setUp(() {
      versionChecker = VersionChecker();
    });

    test('getLatestVersion returns a version', () async {
      final version = await versionChecker.getLatestVersion('dio');
      expect(version, isA<Version>());
    });

    test(
      'checkForNewVersion returns null when no update is available',
      () async {
        final version = Version.parse('1.2.3');
        final newVersion = Version.parse('1.2.3');
        final result = await versionChecker.checkForNewVersion(
          'dio',
          version,
          newVersion: newVersion,
        );
        expect(result, isNull);
      },
    );

    test(
      'checkForNewVersion returns a new version when update is available',
      () async {
        final version = Version.parse('1.2.3');
        final newVersion = Version.parse('1.3.0');
        final result = await versionChecker.checkForNewVersion(
          'dio',
          version,
          newVersion: newVersion,
        );
        expect(result, equals(newVersion));
      },
    );

    test('compareVersions returns null when no update is available', () {
      final current = Version.parse('1.2.3');
      final newer = Version.parse('1.2.3');
      final result = versionChecker.compareVersions(
        current,
        newer,
        Types.minor,
      );
      expect(result, isNull);
    });

    test('compareVersions returns a new version when update is available', () {
      final current = Version.parse('1.2.3');
      final newer = Version.parse('1.3.0');
      final result = versionChecker.compareVersions(
        current,
        newer,
        Types.minor,
      );
      expect(result, equals(newer));
    });

    test('compareVersions returns null when major update is not available', () {
      final current = Version.parse('1.2.3');
      final newer = Version.parse('1.3.0');
      final result = versionChecker.compareVersions(
        current,
        newer,
        Types.major,
      );
      expect(result, isNull);
    });

    test('compareVersions returns null when minor update is not available', () {
      final current = Version.parse('1.2.3');
      final newer = Version.parse('1.2.3+1');
      final result = versionChecker.compareVersions(
        current,
        newer,
        Types.minor,
      );
      expect(result, isNull);
    });

    test('compareVersions returns null when patch update is not available', () {
      final current = Version.parse('1.2.3');
      final newer = Version.parse('1.2.3');
      final result = versionChecker.compareVersions(
        current,
        newer,
        Types.patch,
      );
      expect(result, isNull);
    });
  });
}
