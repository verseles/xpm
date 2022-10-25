import 'package:args/command_runner.dart';

class MakeCommand extends Command {
  @override
  final name = "make";
  @override
  final description = "Makes a build.sh package file";
  @override
  final category = "For developers";

  MakeCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
