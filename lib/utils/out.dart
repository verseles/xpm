import 'dart:io';

import 'package:console/console.dart';

void out(String message,
    {bool error = false,
    List<String>? args,
    Map<String, String>? replace,
    VariableStyle? style,
    VariableResolver? resolver}) {
  final output = error ? stderr : stdout;
  output.writeln(format(message,
      args: args, replace: replace, style: style, resolver: resolver));
}
