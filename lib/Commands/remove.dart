import 'package:args/command_runner.dart';

class RemoveCommand extends Command {
  @override
  final name = "install";
  @override
  final description = "Updates a package";

 RemoveCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
