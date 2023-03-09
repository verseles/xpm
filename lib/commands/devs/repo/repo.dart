import 'package:args/command_runner.dart';
import 'package:xpm/commands/devs/repo/add.dart';
import 'package:xpm/commands/devs/repo/remove.dart';

class RepoCommand extends Command {
  @override
  final name = "repo";
  @override
  final aliases = ['repositories', 'repos', 'repository'];
  @override
  final description = "Manage registered repositories";
  @override
  final category = "For developers";

  RepoCommand() {
    addSubcommand(RepoAddCommand());
    addSubcommand(RepoRemoveCommand());
  }
}
