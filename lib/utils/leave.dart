import 'dart:io';

import 'package:xpm/utils/out.dart';

Never leave({String? message, int exitCode = 1}) {
  if (message != null) {
    out(message);
  }
  exit(exitCode);
}
