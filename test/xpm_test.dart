import 'dart:io';

import 'package:test/test.dart';
import 'package:xpm/xpm.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('XPM', () {
    late File pubspec;
    late String pubspecContent;
    late YamlMap yaml;

    setUp(() async {
      pubspec = File('pubspec.yaml');
      pubspecContent = pubspec.readAsStringSync();
      yaml = loadYaml(pubspecContent);
    });

    test('name should be correct', () {
      expect(XPM.name, yaml['name']);
    });

    test('version should be correct', () {
      expect(XPM.version, yaml['version']);
    });

    test('description should be correct', () {
      expect(XPM.description, yaml['description'].split('.').first);
    });

    test('installMethods should not be empty', () {
      expect(XPM.installMethods, isNotEmpty);
    });

    test('git should return the path to the git executable', () async {
      final git = await XPM.git(['--version']);
      expect(await git.find(), isNotEmpty);
    });

    test('cacheDir should return a directory', () async {
      final dir = await XPM.cacheDir('test');
      expect(await dir.exists(), isTrue);
    });

    test('bash should return the path to the bash executable', () async {
      final bash = await XPM.bash;
      expect(bash, isNotEmpty);
    });

    test('dataDir should return a directory', () async {
      final dir = await XPM.dataDir('test');
      expect(await dir.exists(), isTrue);
    });

    test('temp should return a directory', () async {
      final dir = await XPM.temp('test');
      expect(await dir.exists(), isTrue);
    });

    test('isGit should return true for a git repository', () async {
      expect(await XPM.isGit(Directory.current), isTrue);
    });

    test('isGit should return false for a non-git directory', () async {
      final dir = Directory.systemTemp.createTempSync('xpm_test');
      expect(await XPM.isGit(dir), isFalse);
    });

    test('userHome should return the user home directory', () {
      final userHome = XPM.userHome;
      expect(userHome.path, isNotEmpty);
      expect(userHome.path, equals(Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? Platform.environment['HOMEPATH'] ?? Directory.current.absolute.path));
    });
  });
}
