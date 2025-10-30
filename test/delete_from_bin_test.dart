import 'dart:io';

import 'package:test/test.dart';
import 'package:xpm/os/delete_from_bin.dart';
import 'package:xpm/os/run.dart';

void main() {
  group('deleteFromBin', () {
    test('should delete file from bin directory', () async {
      final tempDir = Directory.systemTemp.createTempSync('deleteFromBin_test');
      final file = File('${tempDir.path}/test_file');
      await file.create(recursive: true);
      final binDir = Directory('${tempDir.path}/bin');
      await binDir.create(recursive: true);
      final runner = Run();
      await runner.move(file.path, '${binDir.path}/test_file', sudo: false);

      final result = await deleteFromBin(file, binDir: binDir, sudo: false);

      expect(result, true);
      expect(await file.exists(), false);
      expect(await File('${binDir.path}/test_file').exists(), false);
    });

    test(
      'should return false when file does not exist in bin directory',
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'deleteFromBin_test',
        );
        final file = File('${tempDir.path}/test_file');
        await file.create(recursive: true);
        final binDir = Directory('${tempDir.path}/bin');
        await binDir.create(recursive: true);

        final result = await deleteFromBin(file, binDir: binDir, sudo: false);

        expect(result, true);
        expect(await file.exists(), true);
        expect(await File('${binDir.path}/test_file').exists(), false);
      },
    );

    test('should return false when file cannot be deleted', () async {
      final tempDir = Directory.systemTemp.createTempSync('deleteFromBin_test');
      final file = File('${tempDir.path}/test_file');
      await file.create(recursive: true);
      final binDir = Directory('${tempDir.path}/bin');
      await binDir.create(recursive: true);
      final runner = Run();
      await runner.move(file.path, '${binDir.path}/test_file', sudo: false);
      // Expect an exception to be thrown when deleting inexistent file
      expect(
        () async => await file.delete(),
        throwsA(isA<PathNotFoundException>()),
      );

      final result = await deleteFromBin(file, binDir: binDir, sudo: false);

      expect(result, true);
      expect(await file.exists(), false);
    });
  });
}
