/// Utility functions for debugging
import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:xpm/utils/json.dart';

/// Dump the variable to the console
///
/// Parameters:
/// - [data]: The variable to dump
void dump(dynamic data) {
  print(serialize(data));
}

/// Dump the variable to the console and exit with success
///
/// Parameters:
/// - [data]: The variable to dump
Never dd(dynamic data) {
  dump(data);
  exit(success);
}
