import 'package:process_run/which.dart';

class Executable {
  final String cmd;

  static final Map<String, Executable> __instance = {};
  static final Map<String, Future<String?>> __which = {};

  Executable._internal(this.cmd);

  factory Executable(String cmd) => __instance.putIfAbsent(cmd, () => Executable._internal(cmd));

  Future<String?> find() async => __which.putIfAbsent(cmd, () async => await which(cmd));

  Future<bool> exists() async => await find() != null;
}
