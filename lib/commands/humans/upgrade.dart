import 'package:args/command_runner.dart';
import 'package:xpm/utils/logger.dart';

class UpgradeCommand extends Command {
  @override
  final name = "upgrade";
  @override
  final aliases = ['up', 'u'];
  @override
  final description = "Upgrade one, many or all packages";
  @override
  final category = "For humans";

  UpgradeCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    Logger.warning('Not implemented yet. Soon.');
  }
}
