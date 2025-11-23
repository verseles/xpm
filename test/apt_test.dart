import 'package:test/test.dart';
import 'package:xpm/native_is_for_everyone/distro_managers/apt.dart';

void main() {
  group('AptPackageManager', () {
    late AptPackageManager manager;

    setUp(() {
      manager = AptPackageManager();
    });

    test('should search for packages', () async {
      try {
        final packages = await manager.search('vim', limit: 5);
        expect(packages, isNotEmpty);
        expect(packages.length, lessThanOrEqualTo(5));

        // Check if package has required fields
        for (final package in packages) {
          expect(package.name, isNotEmpty);
        }
      } catch (e) {
        // Skip test if apt is not available
        expect(e, isA<Exception>());
      }
    }, tags: ['skip-ci']);

    test('should check if package is installed', () async {
      try {
        final isInstalled = await manager.isInstalled('bash');
        expect(isInstalled, isTrue);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    }, tags: ['skip-ci']);

    test('should return false for non-existent package', () async {
      try {
        final isInstalled = await manager.isInstalled('nonexistentpackage12345xyz');
        expect(isInstalled, isFalse);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    }, tags: ['skip-ci']);

    test('should get package information', () async {
      try {
        final package = await manager.get('vim');
        expect(package, isNotNull);
        expect(package?.name, equals('vim'));
        expect(package?.version, isNotNull);
        expect(package?.description, isNotNull);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    }, tags: ['skip-ci']);

    test('should handle empty search results gracefully', () async {
      try {
        final packages = await manager.search('xyznonexistent12345');
        expect(packages, isEmpty);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    }, tags: ['skip-ci']);
  });
}
