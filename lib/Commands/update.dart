import 'package:args/command_runner.dart';

class UpdateCommand extends Command {
  @override
  final name = "update";
  @override
  final description = "Updates a package";

 UpdateCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
