import 'dart:io';
import 'package:test/test.dart';
import 'package:xpm/os/bin_directory.dart';

void main() {
  group('binDirectory', () {
    test('binDirectory returns the path to the system binary folder', () {
      final Directory bin = binDirectory();
      expect(bin.path, isNotNull);
      expect(bin.existsSync(), isTrue);
    });
    test('throws an exception if no binary folder was found', () {
      // Ensure the PATH environment variable does not contain any valid directories
      expect(() => binDirectory(PATH: ''), throwsException);
    });
  });
}
