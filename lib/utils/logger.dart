import 'package:xpm/utils/out.dart';

/// A class for logging messages to the console.
class Logger {
  /// Logs a [message] with the prefix '[LOG]'.
  static String log(String message) {
    String output = '[LOG] $message';
    out(output);

    // Return for testing.
    return output;
  }

  /// Logs an informational [message] in blue.
  static String info(String message) {
    String output = '{@blue}[INFO] $message{@end}';
    out(output);

    // Return for testing.
    return output;
  }

  /// Logs a warning [message] in yellow.
  static String warning(String message) {
    String output = '{@yellow}[WARNING] $message{@end}';
    out(output);

    // Return for testing.
    return output;
  }

  /// Logs an error [message] in red.
  /// If [error] is true, the message will be output to stderr.
  static String error(String message) {
    String output = '{@red}[ERROR] $message{@end}';
    out(output, error: true);

    // Return for testing.
    return output;
  }

  /// Logs a tip [message] in green.
  static String tip(String message) {
    String output = '{@green}$message{@end}';
    out(output);

    // Return for testing.
    return output;
  }
}
