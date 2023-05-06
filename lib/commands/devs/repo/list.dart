import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';

/// A command that lists all repositories.
class ListCommand extends Command {
  @override
  final name = "list";
  @override
  final aliases = ['l', 'ls'];
  @override
  final description = "List all repositories";

  ListCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    // Display a header for the list of repositories.
    out("{@green}List of repositories:{@end}");

    // Get the list of all repositories.
    final reposList = await Repositories.allRepos();

    // Display the URL of each repository.
    for (var repo in reposList) {
      out(repo.url);
    }
  }
}
