import 'package:test/test.dart';
import 'package:xpm/os/get_archicteture.dart';

void main() {
  group('getArchitecture', () {
    test('returns a non-empty string', () {
      final result = getArchitecture();
      expect(result, isNotEmpty);
    });

    test('returns a valid architecture name', () {
      final result = getArchitecture();
      final validArchitectures = ['x86_64', 'x86', 'arm', 'arm64', 'apple-silicon'];
      expect(validArchitectures.contains(result), isTrue);
    });
  });

  group('normalizeCPUName', () {
    test('returns a normalized CPU name', () {
      final cpuName = 'AMD64';
      final result = normalizeCPUName(cpuName);
      expect(result, equals('x86_64'));
    });

    test('returns the original CPU name if not normalized', () {
      final cpuName = 'unknown';
      final result = normalizeCPUName(cpuName);
      expect(result, equals(cpuName));
    });
  });
}
