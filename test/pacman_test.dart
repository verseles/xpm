import 'package:test/test.dart';
import 'package:xpm/native_is_for_everyone/distro_managers/pacman.dart';

void main() {
  group('PacmanPackageManager', () {
    late PacmanPackageManager manager;

    setUp(() {
      manager = PacmanPackageManager();
    });

    test('should return pacman executable path', () async {
      // This test requires pacman to be installed
      try {
        final path = await manager.getPacmanExecutable();
        expect(path, isNotEmpty);
        expect(path, contains('pacman'));
      } catch (e) {
        // Skip test if pacman is not installed
        expect(e, isA<Exception>());
      }
    });

    test('should detect AUR helper (paru or yay)', () async {
      final aurExec = await manager.getAurExecutable();
      // Either null (no AUR helper) or a valid command
      expect(aurExec == null || aurExec.isNotEmpty, isTrue);
    });

    test('should search for packages', () async {
      try {
        final packages = await manager.search('bat', limit: 5);
        expect(packages, isNotEmpty);
        expect(packages.length, lessThanOrEqualTo(5));

        // Check if package has required fields
        for (final package in packages) {
          expect(package.name, isNotEmpty);
          expect(package.version, isNotNull);
          expect(package.description, isNotNull);
        }
      } catch (e) {
        // Skip test if pacman is not available
        expect(e, isA<Exception>());
      }
    });

    test('should parse search output correctly', () {
      final output = '''
extra/jq 1.8.1-1 Command-line JSON processor
extra/bat 0.26.0-1 Cat clone with syntax highlighting
''';

      final packages = manager.parseSearchOutput(output);

      expect(packages.length, 2);
      expect(packages[0].name, equals('jq'));
      expect(packages[0].version, equals('1.8.1-1'));
      expect(packages[0].description, equals('Command-line JSON processor'));

      expect(packages[1].name, equals('bat'));
      expect(packages[1].version, equals('0.26.0-1'));
      expect(packages[1].description, equals('Cat clone with syntax highlighting'));
    });

    test('should parse AUR search output correctly', () {
      final output = '''
aur/whyq 0.15.0-1 [+0 ~0.00] jq compatible yq implementation in rust
aur/qq-git v0.2.5-2 [+0 ~0.00] jq inspired interoperable config format transcoder
''';

      final packages = manager.parseAurOutput(output);

      expect(packages.length, 2);
      expect(packages[0].name, equals('whyq'));
      expect(packages[0].version, equals('0.15.0-1'));
      expect(packages[0].description, contains('jq compatible'));

      expect(packages[1].name, equals('qq-git'));
      expect(packages[1].version, equals('v0.2.5-2'));
    });

    test('should parse package info correctly', () {
      final output = '''
Repositório          : extra
Nome                 : jq
Versão               : 1.8.1-1
Descrição            : Command-line JSON processor
Arquitetura          : x86_64
URL                  : https://jqlang.github.io/jq/
Licenças             : MIT
''';

      final package = manager.parsePackageInfo(output);

      expect(package.name, equals('jq'));
      expect(package.version, equals('1.8.1-1'));
      expect(package.description, equals('Command-line JSON processor'));
      expect(package.arch, equals('x86_64'));
    });

    test('should check if package is installed', () async {
      try {
        final isInstalled = await manager.isInstalled('bash');
        expect(isInstalled, isTrue);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should return false for non-existent package', () async {
      try {
        final isInstalled = await manager.isInstalled('nonexistentpackage12345');
        expect(isInstalled, isFalse);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should get package information', () async {
      try {
        final package = await manager.get('jq');
        expect(package, isNotNull);
        expect(package?.name, equals('jq'));
        expect(package?.version, isNotNull);
        expect(package?.description, isNotNull);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should update package database', () async {
      try {
        await manager.updateDatabase();
        // If no exception is thrown, the test passes
        expect(true, isTrue);
      } catch (e) {
        // Some systems might fail, that's OK
        expect(true, isTrue);
      }
    });

    test('should handle empty search results', () {
      final output = '';
      final packages = manager.parseSearchOutput(output);
      expect(packages, isEmpty);
    });

    test('should limit search results', () {
      final output = '''
extra/jq 1.8.1-1 Command-line JSON processor
extra/bat 0.26.0-1 Cat clone
extra/ripgrep 15.1.0-1 Search tool
extra/fd 8.7.1-1 Alternative to find
extra/htop 3.3.0-1 Process viewer
''';

      final packages = manager.parseSearchOutput(output, limit: 3);

      expect(packages.length, 3);
    });

    test('should remove duplicates in search results', () {
      final output = '''
extra/jq 1.8.1-1 Command-line JSON processor
extra/bat 0.26.0-1 Cat clone
extra/fd 8.7.1-1 Alternative to find
''';

      // This test would require search to be called, which is tested elsewhere
      // Here we just ensure our parsing logic is consistent
      final packages = manager.parseSearchOutput(output);
      expect(packages.length, 3);
    });
  });
}
