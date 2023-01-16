import 'dart:io';

class BashScript {
  final String _filePath;
  BashScript(this._filePath);
  String? _contents;
  bool? _exists;

  Future<bool> exists() async {
    if (_exists != null) {
      return _exists!;
    }
    final file = File(_filePath);
    _exists = await file.exists();
    return _exists!;
  }

  Future<String?> contents() async {
    if (_contents != null) {
      return _contents;
    }
    if (!await exists()) {
      return null;
    }
    _contents = await File(_filePath).readAsString();
    return _contents;
  }

  Future<String?> get(String param) async {
    final contents = await this.contents();

    final regex = RegExp('readonly $param="(.*)"');
    final match = regex.firstMatch(contents ?? '');

    final value = match?.group(1);

    return value;
  }

  Future<Map<String, String?>?> variables() async {
    final contents = await this.contents();
    final regex = RegExp('readonly (.*)="(.*)"');
    final matches = regex.allMatches(contents ?? '');

    if (matches.isEmpty) {
      return null;
    }

    final variables = <String, String?>{};
    for (final match in matches) {
      final variableName = match.group(1);
      final variableValue = await get(variableName!);
      variables[variableName] = variableValue;
    }

    return variables;
  }
}
