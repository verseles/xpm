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

  Future<String?> contents() async {
    _contents ??= await exists() ? await fileInstance!.readAsString() : null;
    return _contents;
  }

  Future<String?> get(String param) async {
    final contents = await this.contents();

    final regex = RegExp('readonly $param="(.*)"');
    final match = regex.firstMatch(contents ?? '');

    final value = match?.group(1);

    return value;
  }

  Future<List<String>?> getArray(String arrayName) async {
    final contents = await this.contents();
    final regex = RegExp('$arrayName=\\((.*?)\\)');
    final match = regex.firstMatch(contents ?? '');
    final arrayValues = match?.group(1)?.split(' ') ?? [];

    return arrayValues;
  }

  Future<String?> getFirstProvides() async {
    final value = await get('xPROVIDES');
    if (value == null) {
      return null;
    }
    final provides = value.split("(").last.split(")").first.split(" ");
    return provides.first;
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

  Future<bool> hasFunction(String functionName) async {
    final contents = await this.contents();
    final regex = RegExp('$functionName\\(.*\\)');
    final matches = regex.allMatches(contents ?? '');

    return matches.isNotEmpty;
  }
}
