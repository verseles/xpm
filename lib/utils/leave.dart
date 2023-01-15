import 'dart:io';

import 'package:xpm/utils/out.dart';
import 'package:all_exit_codes/all_exit_codes.dart';

/// Exits the program with a error message and an error exit code.
Never leave({String? message, int exitCode = generalError}) {
  if (message != null) {
    out(message, error: true);
  }
  exit(exitCode);
}
