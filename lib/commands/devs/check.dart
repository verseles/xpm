import 'package:args/command_runner.dart';

class CheckCommand extends Command {
  @override
  final name = "check";
  @override
  final description = "Checks the build.sh package file specified";
  @override
  final category = "For developers";

  CheckCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
