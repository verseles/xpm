import 'package:test/test.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';

void main() {
  group('NativePackage', () {
    test('should create a NativePackage with all fields', () {
      final package = NativePackage(
        name: 'test-package',
        version: '1.0.0',
        description: 'A test package',
        arch: 'x86_64',
        repo: 'extra',
        popularity: 100,
      );

      expect(package.name, equals('test-package'));
      expect(package.version, equals('1.0.0'));
      expect(package.description, equals('A test package'));
      expect(package.arch, equals('x86_64'));
      expect(package.repo, equals('extra'));
      expect(package.popularity, equals(100));
    });

    test('should create a NativePackage with only required fields', () {
      final package = NativePackage(name: 'minimal-package');

      expect(package.name, equals('minimal-package'));
      expect(package.version, isNull);
      expect(package.description, isNull);
      expect(package.arch, isNull);
      expect(package.repo, isNull);
      expect(package.popularity, isNull);
    });

    test('isAur should return true for AUR packages', () {
      final aurPackage = NativePackage(name: 'aur-pkg', repo: 'aur');
      final extraPackage = NativePackage(name: 'extra-pkg', repo: 'extra');

      expect(aurPackage.isAur, isTrue);
      expect(extraPackage.isAur, isFalse);
    });

    test('isOfficial should return true for official repo packages', () {
      final extraPackage = NativePackage(name: 'pkg', repo: 'extra');
      final corePackage = NativePackage(name: 'pkg', repo: 'core');
      final communityPackage = NativePackage(name: 'pkg', repo: 'community');
      final chaoticPackage = NativePackage(name: 'pkg', repo: 'chaotic-aur');
      final aurPackage = NativePackage(name: 'pkg', repo: 'aur');

      expect(extraPackage.isOfficial, isTrue);
      expect(corePackage.isOfficial, isTrue);
      expect(communityPackage.isOfficial, isTrue);
      expect(chaoticPackage.isOfficial, isTrue);
      expect(aurPackage.isOfficial, isFalse);
    });

    test('toString should return formatted string', () {
      final package = NativePackage(
        name: 'test',
        version: '1.0',
        description: 'desc',
        arch: 'x86_64',
        repo: 'extra',
        popularity: 50,
      );

      final str = package.toString();
      expect(str, contains('name: test'));
      expect(str, contains('version: 1.0'));
      expect(str, contains('description: desc'));
      expect(str, contains('arch: x86_64'));
      expect(str, contains('repo: extra'));
      expect(str, contains('popularity: 50'));
    });

    group('sortForDisplay', () {
      test('should return empty list for empty input', () {
        final result = NativePackage.sortForDisplay([]);
        expect(result, isEmpty);
      });

      test('should sort AUR packages by popularity ascending', () {
        final packages = [
          NativePackage(name: 'pkg-high', repo: 'aur', popularity: 500),
          NativePackage(name: 'pkg-low', repo: 'aur', popularity: 100),
          NativePackage(name: 'pkg-med', repo: 'aur', popularity: 300),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        expect(sorted[0].name, equals('pkg-low'));
        expect(sorted[1].name, equals('pkg-med'));
        expect(sorted[2].name, equals('pkg-high'));
      });

      test('should sort official packages alphabetically', () {
        final packages = [
          NativePackage(name: 'zebra', repo: 'extra'),
          NativePackage(name: 'alpha', repo: 'extra'),
          NativePackage(name: 'mike', repo: 'extra'),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        expect(sorted[0].name, equals('alpha'));
        expect(sorted[1].name, equals('mike'));
        expect(sorted[2].name, equals('zebra'));
      });

      test('should place AUR packages before official packages', () {
        final packages = [
          NativePackage(name: 'official-pkg', repo: 'extra'),
          NativePackage(name: 'aur-pkg', repo: 'aur', popularity: 100),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        expect(sorted[0].repo, equals('aur'));
        expect(sorted[1].repo, equals('extra'));
      });

      test('should handle packages with null popularity', () {
        final packages = [
          NativePackage(name: 'pkg-with-pop', repo: 'aur', popularity: 100),
          NativePackage(name: 'pkg-no-pop', repo: 'aur'),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        // Null popularity treated as 0, so it comes first
        expect(sorted[0].name, equals('pkg-no-pop'));
        expect(sorted[1].name, equals('pkg-with-pop'));
      });

      test('should separate extra/chaotic-aur from other official packages', () {
        final packages = [
          NativePackage(name: 'other-pkg', repo: 'other'),
          NativePackage(name: 'extra-pkg', repo: 'extra'),
          NativePackage(name: 'chaotic-pkg', repo: 'chaotic-aur'),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        // extra/chaotic should come before other official repos
        expect(sorted[0].name, equals('chaotic-pkg'));
        expect(sorted[1].name, equals('extra-pkg'));
        expect(sorted[2].name, equals('other-pkg'));
      });

      test('should handle mixed package types correctly', () {
        final packages = [
          NativePackage(name: 'extra-b', repo: 'extra'),
          NativePackage(name: 'aur-low', repo: 'aur', popularity: 50),
          NativePackage(name: 'other-z', repo: 'core'),
          NativePackage(name: 'aur-high', repo: 'aur', popularity: 200),
          NativePackage(name: 'extra-a', repo: 'extra'),
        ];

        final sorted = NativePackage.sortForDisplay(packages);

        // AUR first (sorted by popularity ascending)
        expect(sorted[0].name, equals('aur-low'));
        expect(sorted[1].name, equals('aur-high'));

        // Then extra (sorted alphabetically)
        expect(sorted[2].name, equals('extra-a'));
        expect(sorted[3].name, equals('extra-b'));

        // Then other official (sorted alphabetically)
        expect(sorted[4].name, equals('other-z'));
      });
    });
  });
}
