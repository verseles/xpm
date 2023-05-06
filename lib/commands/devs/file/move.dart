import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that moves a file or directory.
class FileMoveCommand extends Command {
  @override
  final name = "move";
  @override
  final aliases = ['mv'];
  @override
  String get invocation =>
      '${runner!.executableName} file $name <old path> <new path>';
  @override
  final description = "Move a file or directory";

  /// Creates a new instance of the [FileMoveCommand] class.
  FileMoveCommand() {
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag('force', abbr: 'f', negatable: false, help: 'Force move');
    argParser.addFlag('preserve',
        abbr: 'p', negatable: false, help: 'Preserve attributes');
    argParser.addFlag('verbose',
        abbr: 'v', negatable: true, defaultsTo: true, help: 'Verbose output');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.length != 2, () => printUsage());

    final oldPath = args[0];
    final newPath = args[1];

    final run = Run();
    final moved = await run.move(oldPath, newPath,
        sudo: argResults!['sudo'],
        force: argResults!['force'],
        preserve: argResults!['preserve']);

    final file = File(newPath);
    if (!moved || !file.existsSync()) {
      out("{@red}File '$newPath' not found{@end}");
      exit(unableToOpenOutputFileForWriting);
    }

    if (argResults!['verbose']) {
      out("{@green}File moved to '$newPath'{@end}");
    }

    print(file.absolute.path);
    exit(success);
  }
}
