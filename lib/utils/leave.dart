import 'dart:io';

Never leave({String? message, int exitCode = 1}) {
  if (message != null) {
    print(message);
  }
  exit(exitCode);
}
