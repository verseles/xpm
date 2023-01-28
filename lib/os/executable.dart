import 'package:process_run/which.dart';

class Executable {
  final String cmd;
  static final _whichResults = <String, String?>{};

  const Executable(this.cmd);

  Future<String?> find() async {
    if (_whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = await which(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  Future<bool> exists() async => await find() != null;

  String? findSync() {
    if (_whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = whichSync(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  bool existsSync() => findSync() != null;
}
