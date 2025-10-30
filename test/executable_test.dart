import 'package:test/test.dart';
import 'package:xpm/os/executable.dart';

void main() {
  group('Executable', () {
    test(
      'find method should return the correct path of a given executable',
      () async {
        final executable = Executable('ls');
        final path = await executable.find();
        expect(path, isNotEmpty);
      },
    );

    test(
      'find method should return null if the executable does not exist',
      () async {
        final executable = Executable('nonexistent');
        final path = await executable.find();
        expect(path, isNull);
      },
    );

    test('exists method should return true if the executable exists', () async {
      final executable = Executable('ls');
      final exists = await executable.exists();
      expect(exists, isTrue);
    });

    test(
      'exists method should return false if the executable does not exist',
      () async {
        final executable = Executable('nonexistent');
        final exists = await executable.exists();
        expect(exists, isFalse);
      },
    );

    test(
      'findSync method should return the correct path of a given executable',
      () {
        final executable = Executable('ls');
        final path = executable.findSync();
        expect(path, isNotEmpty);
      },
    );

    test(
      'findSync method should return null if the executable does not exist',
      () {
        final executable = Executable('nonexistent');
        final path = executable.findSync();
        expect(path, isNull);
      },
    );

    test('existsSync method should return true if the executable exists', () {
      final executable = Executable('ls');
      final exists = executable.existsSync();
      expect(exists, isTrue);
    });

    test(
      'existsSync method should return false if the executable does not exist',
      () {
        final executable = Executable('nonexistent');
        final exists = executable.existsSync();
        expect(exists, isFalse);
      },
    );
  });
}
