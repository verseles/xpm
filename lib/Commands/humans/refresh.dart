import 'package:args/command_runner.dart';

class RefreshCommand extends Command {
  @override
  final name = "refresh";
  @override
  final description = "Refresh the package list";
  @override
  final category = "For humans";

  RefreshCommand() {
    argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    print(argResults!['all']);
  }
}
