@Tags(['skip-ci', 'sudo'])
@Skip('This test requires sudo access to move files to the bin directory')
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:xpm/os/bin_directory.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/os/move_to_bin.dart';

void main() {
  group('moveToBin', () {
    test('should move file to bin directory', () async {
      // Create a temporary file for testing
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final testFile = File('${tempDir.path}/test.txt');
      await testFile.writeAsString('test content');

      // Call the moveToBin function
      final binDir = binDirectory();
      final runner = Run();
      final fileInBinDir = await moveToBin(
        testFile,
        binDir: binDir,
        runner: runner,
      );
      expect(fileInBinDir, isNotNull);

      // Check that the file was moved to the bin directory
      expect(await fileInBinDir!.exists(), isTrue);
      expect(await fileInBinDir.readAsString(), equals('test content'));

      // Clean up the temporary file and the file in the bin directory
      await runner.delete(testFile.path, sudo: true);
      await runner.delete(fileInBinDir.path, sudo: true);
      await runner.delete(tempDir.path, sudo: true, recursive: true);
    });

    test(
      'should return null if file cannot be moved to bin directory',
      () async {
        // Create a file in a non-existent directory
        final testFile = File('non-existent-dir/test.txt');

        // Call the moveToBin function
        final success = await moveToBin(testFile);

        // Check that the function returns null
        expect(success, isNull);
      },
    );
  });
}
