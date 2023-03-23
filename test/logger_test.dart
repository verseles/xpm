import 'package:test/test.dart';
import 'package:xpm/utils/logger.dart';

void main() {
  test('log() logs message with prefix [LOG]', () {
    String message = 'This is a log message.';
    String expected = '[LOG] $message';
    String result = Logger.log(message);
    expect(result, equals(expected));
  });

  test('info() logs message in blue', () {
    String message = 'This is an info message.';
    String expected = '{@blue}[INFO] $message{@end}';
    String result = Logger.info(message);
    expect(result, equals(expected));
  });

  test('warning() logs message in yellow', () {
    String message = 'This is a warning message.';
    String expected = '{@yellow}[WARNING] $message{@end}';
    String result = Logger.warning(message);
    expect(result, equals(expected));
  });

  test('error() logs message in red', () {
    String message = 'This is an error message.';
    String expected = '{@red}[ERROR] $message{@end}';
    String result = Logger.error(message);
    expect(result, equals(expected));
  });

  test('tip() logs message in green', () {
    String message = 'This is a tip message.';
    String expected = '{@green}[TIP] $message{@end}';
    String result = Logger.tip(message);
    expect(result, equals(expected));
  });
}
