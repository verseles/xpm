import 'package:process_run/which.dart';

final _whichResults = <String, Future<String?>>{};

class Executable {
  final String cmd;

  const Executable(this.cmd);

  Future<String?> find() async =>
      _whichResults.putIfAbsent(cmd, () async => await which(cmd));

  Future<bool> exists() async => await find() != null;
}
