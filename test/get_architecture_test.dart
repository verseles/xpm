import 'package:test/test.dart';
import 'package:xpm/os/get_archicteture.dart';

void main() {
  test('getArchitecture function should not be unknown', () async {
    final architecture = getArchitecture();
    expect(architecture, isNot(equals('unknown')));
  });
}
