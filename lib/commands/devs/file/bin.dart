import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/move_to_bin.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class FileBinCommand extends Command {
  @override
  final name = "bin";
  @override
  String get invocation => '${runner!.executableName} file $name <file path>';
  @override
  final description = "Move a file to the system bin directory";

  FileBinCommand() {
    argParser.addFlag('verbose',
        abbr: 'v', negatable: true, defaultsTo: true, help: 'Verbose output');
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag('exec',
        abbr: 'x', negatable: false, help: 'Mark as executable');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.isEmpty, () => printUsage());

    final filePath = args[0];

    final file = File(filePath);
    final sudo = argResults!['sudo'] && await Executable('sudo').exists();
    final moved = await moveToBin(file, sudo: sudo);

    if (moved == null) {
      out("{@red}Failed to move '${file.absolute.path}' to bin{@end}");
      exit(unableToOpenOutputFileForWriting);
    }

    final finalPath = moved.path;

    if (argResults!['verbose']) {
      out("{@green}File moved to bin: '$finalPath'{@end}");
    }

    if (argResults!['exec']) {
      final run = Run();
      final marked = await run.asExec(finalPath, sudo: argResults!['sudo']);

      if (!marked) {
        out("{@red}Failed to mark '$finalPath' as executable{@end}");
        exit(cantExecute);
      }

      if (argResults!['verbose']) {
        out("{@green}File marked as executable: '$finalPath'{@end}");
      }
    }

    print(finalPath);
    exit(success);
  }
}
