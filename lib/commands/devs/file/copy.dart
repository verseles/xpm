import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class FileCopyCommand extends Command {
  @override
  final name = "copy";
  @override
  final aliases = ['cp'];
  @override
  String get invocation =>
      '${runner!.executableName} file $name <old path> <new path>';
  @override
  final description = "Copy a file or directory";

  FileCopyCommand() {
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag('recursive',
        abbr: 'r', negatable: false, help: 'Copy recursively');
    argParser.addFlag('force', abbr: 'f', negatable: false, help: 'Force copy');
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
    final copied = await run.copy(oldPath, newPath,
        sudo: argResults!['sudo'],
        recursive: argResults!['recursive'],
        force: argResults!['force'],
        preserve: argResults!['preserve']);

    final file = File(newPath);
    if (!copied || !file.existsSync()) {
      out("{@red}File '$newPath' not found{@end}");
      exit(unableToOpenOutputFile);
    }

    if (argResults!['verbose']) {
      out("{@green}File copied to '$newPath'{@end}");
    }

    print(file.absolute.path);
    exit(success);
  }
}
