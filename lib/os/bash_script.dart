import 'dart:io';

class BashScript {
  final String _filePath;
  BashScript(this._filePath);
  String? _contents;
  bool? _exists;
  File? fileInstance;

  Future<bool> exists() async {
    fileInstance ??= File(_filePath);
    _exists ??= await fileInstance!.exists();
    return _exists!;
  }

  bool existsSync() {
    fileInstance ??= File(_filePath);
    _exists ??= fileInstance!.existsSync();
    return _exists!;
  }

  Future<String?> contents() async {
    _contents ??= await exists() ? await fileInstance!.readAsString() : null;
    return _contents;
  }

  // contents sync
  String? contentsSync() {
    _contents ??= existsSync() ? fileInstance!.readAsStringSync() : null;
    return _contents;
  }

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
    if (value == null) {
      return null;
    }
    return value.first;
  }

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
