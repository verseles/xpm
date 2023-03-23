import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';

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
    out("{@green}List of repositories:{@end}");
    final reposList = await Repositories.allRepos();

    for (var repo in reposList) {
      out(repo.url);
    }
  }
}
