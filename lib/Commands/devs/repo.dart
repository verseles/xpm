import 'package:args/command_runner.dart';

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
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
