import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:test/test.dart';
import 'package:xpm/utils/checksum.dart';
import 'package:xpm/xpm.dart';

void main() async {
  Directory testDir = await XPM.temp('tests');

  group('Checksum', () {
    test('check() returns true for a valid hash', () async {
      final file = File('${testDir.path}/test1.txt');
      await file.writeAsString('Hello, world!');

      final checksum = Checksum();
      final result = await checksum.check(file, sha1, '943a702d06f34599aee1f8da8ef9f7296031d699');

      expect(result, isTrue);
      file.delete();
    });

    test('check() returns false for an invalid hash', () async {
      final file = File('${testDir.path}/test2.txt');
      await file.writeAsString('Hello, world!');

      final checksum = Checksum();
      final result = await checksum.check(file, sha256, 'invalid hash');

      expect(result, isFalse);
      file.delete();
    });
  });
}
