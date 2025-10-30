import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that adds a new git repository to the list of repositories.
class RepoAddCommand extends Command {
  @override
  final name = "add";
  @override
  final aliases = ['a'];
  @override
  String get invocation =>
      '${runner!.executableName} repo $name <repository url>';
  @override
  final description = "Add a new git repository to the list of repositories";

  RepoAddCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    // Show usage if no arguments are provided.
    showUsage(args.isEmpty, () => printUsage());

    // Get the repository URL from the command line arguments.
    final remote = args[0];

    // Add the repository to the list of repositories.
    Repositories.addRepo(remote);

    // Display a success message.
    out("{@green}Repo added to the list of repos{@end}");
  }
}
