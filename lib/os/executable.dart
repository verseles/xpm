import 'package:process_run/which.dart';

class Executable {
  final String cmd;
  static final _whichResults = <String, String?>{};

  const Executable(this.cmd);

  Future<String?> find({bool cache = true}) async {
    if (cache && _whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = await which(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  Future<bool> exists({bool cache = true}) async => await find(cache: cache) != null;

  String? findSync({bool cache = true}) {
    if (_whichResults.containsKey(cmd)) {
      return _whichResults[cmd];
    }
    final result = whichSync(cmd);
    _whichResults[cmd] = result;
    return result;
  }

  bool existsSync({bool cache = true}) => findSync(cache: cache) != null;
}
