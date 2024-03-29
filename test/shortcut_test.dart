@Tags(['skip-ci'])

import 'dart:io';

import 'package:test/test.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/os/shortcut.dart';
import 'package:xpm/xpm.dart';

void main() async {
  group('Shortcut', () {
    test('creates a Linux shortcut correctly', () async {
      final shortcut = Shortcut(
          name: 'test_shortcut',
          executablePath: '/usr/bin/test_app',
          destination: (await XPM.temp('tests')).path,
          sudo: false);

      var filePath = await shortcut.create();
      var runner = Run();

      expect(await runner.exists(filePath, sudo: false), isTrue);

      await runner.delete(filePath, sudo: false);
    }, testOn: 'linux');

    test('creates a macOS shortcut correctly', () async {
      final shortcut = Shortcut(
        name: 'test_shortcut',
        executablePath: '/Applications/test_app.app',
      );

      final file = File(await shortcut.create());
      expect(await file.exists(), isTrue);
    }, testOn: 'mac-os', tags: 'not-tested');

    test('creates a Windows shortcut correctly', () async {
      final shortcut = Shortcut(
        name: 'test_shortcut',
        executablePath: 'C:\\Program Files\\test_app.exe',
      );

      final file = File(await shortcut.create());
      expect(await file.exists(), isTrue);
    }, testOn: 'windows', tags: 'not-tested');
  });
}
