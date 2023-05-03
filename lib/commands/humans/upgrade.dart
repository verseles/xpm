import 'package:args/command_runner.dart';
import 'package:xpm/utils/logger.dart';

/// A command that upgrades one, many, or all packages.
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
    // Add options and flags for the command.
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // TODO: Implement the upgrade functionality.
    Logger.warning('Not implemented yet. Soon.');
  }
}

