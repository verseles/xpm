import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
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

  /// Logs a success [message] in green.
  static String success(String message, {bool error = true}) {
    String output = '{@green}[INFO] $message{@end}';
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
  /// If [exitCode] is not null, the process will exit with the given exit code.
  static String error(String message, {bool error = true, int? exitCode = generalError}) {
    String output = '{@red}[ERROR] $message{@end}';
    out(output, error: error);

    if (exitCode != null) {
      exit(exitCode);
    }
    
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
