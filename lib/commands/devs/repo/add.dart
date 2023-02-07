import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class RepoAddCommand extends Command {
  @override
  final name = "add";
  @override
  final aliases = ['a'];
  @override
  String get invocation => '${runner!.executableName} $name <repository url>';
  @override
  final description = "Add a new git repository to the list of repositories";

  RepoAddCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.isEmpty, () => printUsage());

    final remote = args[0];

    Repositories.addRepo(remote);

    out("{@green}Repo added to the list of repos{@end}");
  }
}
