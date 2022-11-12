import 'package:process_run/which.dart';

class Executable {
  final String cmd;

  static final Map<String, Executable> _cache = {};

  factory Executable(String cmd) => _cache.putIfAbsent(cmd, () => Executable._internal(cmd));

  Executable._internal(this.cmd);

  Future<String?> find() async => await which(cmd);

  Future<bool> exists() async => await find() != null;

}
