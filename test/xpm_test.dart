import 'dart:io';

import 'package:xpm/xpm.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
// Check if the version is correct.
  test('check version', () {
    final pubspec = File('pubspec.yaml');
    final pubspecContent = pubspec.readAsStringSync();
    final yaml = loadYaml(pubspecContent);
    expect(yaml['version'], XPM.version);
  });
}
