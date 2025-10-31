import 'dart:io';

import 'package:console/console.dart';

/// Writes a message to the console output stream.
///
/// The [message] parameter is the message to be written to the console.
///
/// The [error] parameter indicates whether the message should be written to the standard error stream instead of the standard output stream. The default value is `false`.
///
/// The [args] parameter is a list of arguments to be used to replace placeholders in the message. The placeholders are represented by curly braces (`{}`) and are replaced by the corresponding argument in the list. The default value is `null`.
///
/// The [replace] parameter is a map of key-value pairs to be used to replace placeholders in the message. The keys represent the placeholders and the values represent the replacement values. The default value is `null`.
///
/// The [style] parameter is an enum value that specifies the style of the variables in the message. The default value is `null`, which means that the variables will be printed in their default style.
///
/// The [resolver] parameter is a function that takes a variable name and returns its value. It is used to resolve variables in the message. The default value is `null`, which means that variables will not be resolved.
void out(
  String message, {
  bool error = false,
  List<String>? args,
  Map<String, String>? replace,
  VariableStyle? style,
  VariableResolver? resolver,
}) {
  final output = error ? stderr : stdout;

  output.writeln(format(message, args: args, replace: replace, style: style, resolver: resolver));

  // exit does not work here since the write process is non-blocking (async)
}
