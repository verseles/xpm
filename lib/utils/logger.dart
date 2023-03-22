import 'package:xpm/utils/out.dart';

/// A class for logging messages to the console.
/// All methods use stderr for output by default to avoid conflicts with stdout.
class Logger {
  /// Logs a [message] with the prefix '[LOG]'.
  static String log(String message, {bool error = true}) {
    String output = '[LOG] $message';
    out(output, error: error);

    // Return for testing.
    return output;
  }

  /// Logs an informational [message] in blue.
  static String info(String message, {bool error = true}) {
    String output = '{@blue}[INFO] $message{@end}';
    out(output, error: error);

    // Return for testing.
    return output;
  }

  /// Logs a warning [message] in yellow.
  static String warning(String message, {bool error = true}) {
    String output = '{@yellow}[WARNING] $message{@end}';
    out(output, error: error);

    // Return for testing.
    return output;
  }

  /// Logs an error [message] in red.
  /// If [error] is true, the message will be output to stderr.
  static String error(String message, {bool error = true}) {
    String output = '{@red}[ERROR] $message{@end}';
    out(output, error: error);

    // Return for testing.
    return output;
  }

  /// Logs a tip [message] in green.
  static String tip(String message, {bool error = true}) {
    String output = '{@green}[TIP] $message{@end}';
    out(output, error: error);

    // Return for testing.
    return output;
  }
}
