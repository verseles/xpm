import 'package:args/command_runner.dart';

class RemoveCommand extends Command {
  @override
  final name = "remove";
  @override
  final description = "Removes a package";
  @override
  final category = "For humans";

  RemoveCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
