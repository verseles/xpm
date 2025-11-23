import 'dart:io';
import 'package:test/test.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';

void main() {
  group('DB', () {
    test('should get database instance', () async {
      final db = await DB.instance();
      expect(db, isNotNull);
    });

    test('should return same instance on multiple calls', () async {
      final db1 = await DB.instance();
      final db2 = await DB.instance();
      expect(identical(db1, db2), isTrue);
    });

    test('should have packages collection', () async {
      final db = await DB.instance();
      expect(db.packages, isNotNull);
    });

    test('should have repos collection', () async {
      final db = await DB.instance();
      expect(db.repos, isNotNull);
    });

    test('should have kVs collection', () async {
      final db = await DB.instance();
      expect(db.kVs, isNotNull);
    });
  });

  group('Package', () {
    late Package package;

    setUp(() {
      package = Package()
        ..name = 'test-package'
        ..version = '1.0.0'
        ..desc = 'A test package'
        ..title = 'Test Package'
        ..url = 'https://example.com';
    });

    test('should create a package with all fields', () {
      expect(package.name, equals('test-package'));
      expect(package.version, equals('1.0.0'));
      expect(package.desc, equals('A test package'));
      expect(package.title, equals('Test Package'));
      expect(package.url, equals('https://example.com'));
    });

    test('should have nullable installation fields', () {
      expect(package.installed, isNull);
      expect(package.method, isNull);
      expect(package.channel, isNull);
    });

    test('should allow setting installation fields', () {
      package.installed = '1.0.0';
      package.method = 'apt';
      package.channel = 'stable';

      expect(package.installed, equals('1.0.0'));
      expect(package.method, equals('apt'));
      expect(package.channel, equals('stable'));
    });

    test('should have arch list', () {
      package.arch = ['x86_64', 'arm64'];
      expect(package.arch, contains('x86_64'));
      expect(package.arch, contains('arm64'));
    });

    test('should have methods list', () {
      package.methods = ['apt', 'pacman', 'any'];
      expect(package.methods, contains('apt'));
      expect(package.methods, contains('pacman'));
      expect(package.methods, contains('any'));
    });

    test('should have defaults list', () {
      package.defaults = ['apt'];
      expect(package.defaults, contains('apt'));
    });

    test('should have isNative flag', () {
      expect(package.isNative, isNull);
      package.isNative = true;
      expect(package.isNative, isTrue);
    });
  });

  group('Repo', () {
    test('should create a repo with url', () {
      final repo = Repo()..url = 'https://github.com/example/repo';
      expect(repo.url, equals('https://github.com/example/repo'));
    });

    test('should have packages backlink', () {
      final repo = Repo()..url = 'https://github.com/example/repo';
      expect(repo.packages, isNotNull);
    });
  });

  group('Database operations', () {
    test('should write and read a package', () async {
      final db = await DB.instance();
      final testPackage = Package()
        ..name = 'db-test-package-${DateTime.now().millisecondsSinceEpoch}'
        ..version = '1.0.0'
        ..desc = 'Test package for DB test';

      // Write
      await db.writeTxn(() async {
        await db.packages.put(testPackage);
      });

      // Read
      final found = await db.packages.filter().nameEqualTo(testPackage.name).findFirst();

      expect(found, isNotNull);
      expect(found?.name, equals(testPackage.name));
      expect(found?.version, equals('1.0.0'));

      // Cleanup
      await db.writeTxn(() async {
        if (found != null) {
          await db.packages.delete(found.id);
        }
      });
    });

    test('should update a package', () async {
      final db = await DB.instance();
      final testName = 'db-update-test-${DateTime.now().millisecondsSinceEpoch}';
      final testPackage = Package()
        ..name = testName
        ..version = '1.0.0';

      // Write
      await db.writeTxn(() async {
        await db.packages.put(testPackage);
      });

      // Update
      testPackage.version = '2.0.0';
      await db.writeTxn(() async {
        await db.packages.put(testPackage);
      });

      // Read
      final found = await db.packages.filter().nameEqualTo(testName).findFirst();
      expect(found?.version, equals('2.0.0'));

      // Cleanup
      await db.writeTxn(() async {
        if (found != null) {
          await db.packages.delete(found.id);
        }
      });
    });

    test('should delete a package', () async {
      final db = await DB.instance();
      final testName = 'db-delete-test-${DateTime.now().millisecondsSinceEpoch}';
      final testPackage = Package()
        ..name = testName
        ..version = '1.0.0';

      // Write
      await db.writeTxn(() async {
        await db.packages.put(testPackage);
      });

      // Delete
      await db.writeTxn(() async {
        await db.packages.delete(testPackage.id);
      });

      // Verify deleted
      final found = await db.packages.filter().nameEqualTo(testName).findFirst();
      expect(found, isNull);
    });

    test('should search packages by name', () async {
      final db = await DB.instance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testPackages = [
        Package()
          ..name = 'search-test-alpha-$timestamp'
          ..version = '1.0.0',
        Package()
          ..name = 'search-test-beta-$timestamp'
          ..version = '1.0.0',
        Package()
          ..name = 'other-package-$timestamp'
          ..version = '1.0.0',
      ];

      // Write
      await db.writeTxn(() async {
        for (final pkg in testPackages) {
          await db.packages.put(pkg);
        }
      });

      // Search
      final found = await db.packages.filter().nameContains('search-test').findAll();

      expect(found.length, greaterThanOrEqualTo(2));
      expect(found.any((p) => p.name.contains('alpha')), isTrue);
      expect(found.any((p) => p.name.contains('beta')), isTrue);

      // Cleanup
      await db.writeTxn(() async {
        for (final pkg in testPackages) {
          await db.packages.delete(pkg.id);
        }
      });
    });
  });
}
