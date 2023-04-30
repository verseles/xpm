import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class FileDeleteCommand extends Command {
  @override
  final name = "delete";
  @override
  final aliases = ['rm', 'del', 'remove'];
  @override
  String get invocation => '${runner!.executableName} file $name <file path>';
  @override
  final description = "Delete a file or directory";

  FileDeleteCommand() {
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag('recursive',
        abbr: 'r', negatable: false, help: 'Delete recursively');
    argParser.addFlag('force',
        abbr: 'f', negatable: false, help: 'Force delete');
    argParser.addFlag('verbose',
        abbr: 'v', negatable: true, defaultsTo: true, help: 'Verbose output');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> files = argResults!.rest;

    showUsage(files.isEmpty, () => printUsage());

    for (String path in files) {
      final filePath = path;
      final file = File(filePath);

      if (!file.existsSync() && !argResults!['force']) {
        out("{@red}File '$filePath' not found{@end}");
        exit(unableToOpenInputFile);
      }

      final run = Run();
      final deleted = await run.delete(filePath,
          sudo: argResults!['sudo'],
          recursive: argResults!['recursive'],
          force: argResults!['force']);

      if (!deleted || file.existsSync() && !argResults!['force']) {
        out("{@red}Failed to delete '$filePath'{@end}");
        exit(ioError);
      }

      if (argResults!['verbose']) {
        out("{@green}File deleted: '$filePath'{@end}");
      }
    }

    exit(success);
  }
}
