import 'package:test/test.dart';
import 'package:xpm/utils/version_checker.dart';

void main() {
  group('VersionChecker', () {
    late VersionChecker versionChecker;

    setUp(() {
      versionChecker = VersionChecker();
    });

    test('checkForNewVersion returns new minor version', () async {
      final packageName = 'test_package';
      final newVersion = await versionChecker.checkForNewVersion(packageName, type: 'minor');
      expect(newVersion, isNotNull);
      expect(newVersion, isA<String>());
    });

    test('checkForNewVersion returns new major version', () async {
      final packageName = 'test_package';
      final newVersion = await versionChecker.checkForNewVersion(packageName, type: 'major');
      expect(newVersion, isNotNull);
      expect(newVersion, isA<String>());
    });

    test('checkForNewVersion returns new patch version', () async {
      final packageName = 'test_package';
      final newVersion = await versionChecker.checkForNewVersion(packageName, type: 'patch');
      expect(newVersion, isNotNull);
      expect(newVersion, isA<String>());
    });

    test('checkForNewVersion throws ArgumentError for invalid type', () {
      final packageName = 'test_package';
      expect(() async => await versionChecker.checkForNewVersion(packageName, type: 'invalid'), throwsA(isA<ArgumentError>()));
    });
  });
}
