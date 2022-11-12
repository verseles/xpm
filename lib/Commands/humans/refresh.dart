import 'package:args/command_runner.dart';
import 'package:xpm/OS/repositories.dart';

class RefreshCommand extends Command {
  @override
  final name = "refresh";
  @override
  final aliases = ['ref'];
  @override
  final description = "Refresh the package list";
  @override
  final category = "For humans";

  RefreshCommand() {
    argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    final repos = Repositories();
    repos.getPopular();

  }
}
