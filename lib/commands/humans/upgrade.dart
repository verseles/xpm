import 'package:args/command_runner.dart';

class UpgradeCommand extends Command {
  @override
  final name = "upgrade";
  @override
  final aliases = ['full', 'full-upgrade', 'fu'];
  @override
  final description = "Upgrades all installed packages via XPM";
  @override
  final category = "For humans";

  UpgradeCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
