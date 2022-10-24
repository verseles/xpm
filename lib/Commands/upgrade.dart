import 'package:args/command_runner.dart';

class UpgradeCommand extends Command {
  @override
  final name = "upgrade";
  @override
  final description = "Upgrade all installed packages via XPM";

 UpgradeCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
