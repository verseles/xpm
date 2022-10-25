import 'package:args/command_runner.dart';

class InstallCommand extends Command {
  @override
  final name = "install";
  @override
  final description = "Install a package";
  @override
  final category = "For humans";

  InstallCommand() {
    argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    print(argResults!['all']);
  }
}
