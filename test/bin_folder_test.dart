import 'dart:io';
import 'package:test/test.dart';
import 'package:xpm/os/bin_folder.dart';

void main() {
  group('binFolder', () {
    test('binFolder returns the path to the system binary folder', () {
      final Directory bin = binFolder();
      expect(bin.path, isNotNull);
      expect(bin.existsSync(), isTrue);
    });
    test('throws an exception if no binary folder was found', () {
      // Ensure the PATH environment variable does not contain any valid directories
      expect(() => binFolder(PATH: ''), throwsException);
    });
  });
}
