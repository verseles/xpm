import 'package:xpm/utils/out.dart';

class Logger {
  static void log(String message) {
    out('[LOG] $message');
  }

  static void info(String message) {
    out('{@blue}[INFO] $message{@end}');
  }

  static void warning(String message) {
    out('{@yellow}[WARNING] $message{@end}');
  }

  static void error(String message) {
    out('{@red}[ERROR] $message{@end}', error: true);
  }

  static void tip(String message) {
    out('{@green}$message{@end}');
  }
}
