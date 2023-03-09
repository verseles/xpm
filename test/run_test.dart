import 'dart:io';

import 'package:test/test.dart';
import 'package:xpm/os/run.dart';

void main() {
  group('Run', () {
    late Run runner;
    late Directory tempDir;

    setUp(() async {
      runner = Run();
      tempDir = await Directory.systemTemp.createTemp('test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('simple command execution', () async {
      ProcessResult result = await runner.simple('echo', ['Hello, world!']);
      expect(result.exitCode, equals(0));
      expect(result.stdout, equals('Hello, world!\n'));
    });

    test('write to file', () async {
      String filePath = '${tempDir.path}/test_file.txt';
      String text = 'Hello, world!';
      bool success = await runner.writeToFile(filePath, text);
      expect(success, isTrue);

      File file = File(filePath);
      String originalText = await file.readAsString();
      expect(originalText.trim(), equals(text.trim()));

      await file.delete();
    });

    test('create empty file', () async {
      String filePath = '${tempDir.path}/test_file.txt';
      bool success = await runner.touch(filePath);
      expect(success, isTrue);

      File file = File(filePath);
      expect(await file.exists(), isTrue);

      await file.delete();
    });

    test('give executable permissions', () async {
      String filePath = '${tempDir.path}/test_file.txt';
      bool success = await runner.touch(filePath);
      expect(success, isTrue);

      success = await runner.asExec(filePath);
      expect(success, isTrue);

      FileStat stat = await FileStat.stat(filePath);
      expect(stat.mode & 0x1, isNot(0));

      await runner.delete(filePath);
    });

    test('delete file', () async {
      String filePath = '${tempDir.path}/test_file.txt';
      bool success = await runner.writeToFile(filePath, 'Hello, world!');
      expect(success, isTrue);

      success = await runner.delete(filePath);
      expect(success, isTrue);

      File file = File(filePath);
      expect(await file.exists(), isFalse);
    });

    test('rename or move file', () async {
      String oldPath = '${tempDir.path}/old_file.txt';
      String newPath = '${tempDir.path}/new_file.txt';
      String text = 'Hello, world!';
      bool success = await runner.writeToFile(oldPath, text);
      expect(success, isTrue);

      success = await runner.move(oldPath, newPath);
      expect(success, isTrue);

      File file = File(newPath);
      String originalText = await file.readAsString();
      expect(originalText.trim(), equals(text.trim()));

      await file.delete();
    });

    test('copy file', () async {
      String sourcePath = '${tempDir.path}/source_file.txt';
      String destPath = '${tempDir.path}/dest_file.txt';
      String text = 'Hello, world!';
      bool success = await runner.writeToFile(sourcePath, text);
      expect(success, isTrue);

      success = await runner.copy(sourcePath, destPath);
      expect(success, isTrue);

      File sourceFile = File(sourcePath);
      File destFile = File(destPath);
      expect(await sourceFile.exists(), isTrue);
      expect(await destFile.exists(), isTrue);

      String originalText = await sourceFile.readAsString();
      String copiedText = await destFile.readAsString();
      expect(originalText.trim(), equals(text.trim()));
      expect(copiedText.trim(), equals(text.trim()));

      await sourceFile.delete();
      await destFile.delete();
    });

    test('check if file exists', () async {
      String filePath = '${tempDir.path}/test_file.txt';
      String text = 'Hello, world!';
      bool success = await runner.writeToFile(filePath, text);
      expect(success, isTrue);

      expect(await runner.exists(filePath), isTrue);
      expect(await runner.exists('non_existent_file.txt'), isFalse);

      await runner.delete(filePath);
    });
  });
}
