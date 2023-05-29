import 'dart:io';

/// A class that represents a Bash script file.
class BashScript {
  final String _filePath;
  BashScript(this._filePath);
  String? _contents;
  bool? _exists;
  File? fileInstance;

  /// Returns `true` if the script file exists.
  Future<bool> exists() async {
    fileInstance ??= File(_filePath);
    _exists ??= await fileInstance!.exists();
    return _exists!;
  }

  /// Returns `true` if the script file exists.
  bool existsSync() {
    fileInstance ??= File(_filePath);
    _exists ??= fileInstance!.existsSync();
    return _exists!;
  }

  /// Returns the contents of the script file.
  ///
  /// Returns `null` if the file does not exist.
  Future<String?> contents() async {
    _contents ??= await exists() ? await fileInstance!.readAsString() : null;
    return _contents;
  }

  /// Returns the contents of the script file.
  ///
  /// Returns `null` if the file does not exist.
  String? contentsSync() {
    _contents ??= existsSync() ? fileInstance!.readAsStringSync() : null;
    return _contents;
  }

  /// Returns the value of a variable in the script file.
  ///
  /// The [param] parameter is the name of the variable.
  ///
  /// Returns `null` if the variable is not found or the file does not exist.
  Future<String?> get(String param) async {
    final script = await contents();
    if (script == null) {
      return null;
    }
    final regex = RegExp('readonly $param="(.*)"');
    final match = regex.firstMatch(script);

    final value = match?.group(1);

    return value;
  }

  /// Returns the array with the specified name from the script.
  ///
  /// If the script does not exist, returns null.
  /// If the array does not exist, returns null.
  ///
  /// [arrayName] is the name of the array to return.
  ///
  /// The script must be in the form:
  ///     var arrayName = [...];
  /// The array should be a list of strings, which may be enclosed in single quotes.
  /// The strings will be stripped of their single quotes.
  Future<List<String>?> getArray(String arrayName) async {
    final script = await contents();
    if (script == null) {
      return null;
    }
    final regex = RegExp('$arrayName=\\((.*?)\\)');
    final match = regex.firstMatch(script);

    if (match == null) {
      return null;
    }

    final array = match.group(1)?.split(' ') ?? [];

    return array.map((str) => str.replaceAll(RegExp("^'|'\$"), "")).toList();
  }

  /// Returns the first value of the PROVIDES array.
  Future<String?> getFirstProvides() async {
    final value = await getArray('xPROVIDES');
    if (value == null || value.isEmpty || value.first.isEmpty) {
      return null;
    }
    return value.first;
  }

  /// Returns a map of all variables in the script file.
  ///
  /// The keys of the map are the variable names, and the values are the variable values.
  ///
  /// Returns `null` if the file does not exist or if no variables are found.
  Future<Map<String, String?>?> variables() async {
    final script = await contents();
    if (script == null) {
      return null;
    }
    final regex = RegExp('readonly (.*)="(.*)"');
    final matches = regex.allMatches(script);

    if (matches.isEmpty) {
      return null;
    }

    final variables = <String, String?>{};
    for (final match in matches) {
      final variableName = match.group(1)!;
      final variableValue = await get(variableName);
      variables[variableName] = variableValue;
    }

    return variables;
  }

  /// Returns `true` if the script file contains a function with the given [functionName].
  ///
  /// Returns `false` if the file does not exist or if the function is not found.
  Future<bool> hasFunction(String functionName) async {
    final script = await contents();
    if (script == null) {
      return false;
    }

    final lines = script.split('\n');
    for (final line in lines) {
      if (line.startsWith('$functionName() {')) {
        return true;
      }
    }

    return false;
  }
}
