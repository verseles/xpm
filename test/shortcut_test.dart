import 'dart:io';

import 'package:test/test.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/os/shortcut.dart';

void main() async {
  group('Shortcut', () {
    test('creates a Linux shortcut correctly', () async {
      final shortcut = Shortcut(
        name: 'test_shortcut',
        executablePath: '/usr/bin/test_app',
      );

      var filePath = await shortcut.create();
      var runner = Run();

      expect(await runner.exists(filePath, sudo: true), isTrue);

      await runner.delete(filePath, sudo: true);
    }, testOn: 'linux', tags: ['sudo', 'untested']);

    test('creates a macOS shortcut correctly', () async {
      final shortcut = Shortcut(
        name: 'test_shortcut',
        executablePath: '/Applications/test_app.app',
      );

      final file = File(await shortcut.create());
      expect(await file.exists(), isTrue);
    }, testOn: 'mac-os', tags: 'sudo');

    test('creates a Windows shortcut correctly', () async {
      final shortcut = Shortcut(
        name: 'test_shortcut',
        executablePath: 'C:\\Program Files\\test_app.exe',
      );

      final file = File(await shortcut.create());
      expect(await file.exists(), isTrue);
    }, testOn: 'windows', tags: 'untested');
  });
}
