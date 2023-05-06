import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/move_to_bin.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that moves a file to the system bin directory.
class FileBinCommand extends Command {
  @override
  final name = "bin";
  @override
  String get invocation => '${runner!.executableName} file $name <file path>';
  @override
  final description = "Move a file to the system bin directory";

  FileBinCommand() {
    argParser.addFlag('verbose', abbr: 'v', negatable: true, defaultsTo: true, help: 'Verbose output');
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag('exec', abbr: 'x', negatable: false, help: 'Mark as executable');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    // Show usage if no arguments are provided.
    showUsage(args.isEmpty, () => printUsage());

    // Get the file path from the command line arguments.
    final filePath = args[0];

    // Create a file object from the file path.
    final file = File(filePath);

    // Determine if the command should be run with sudo.
    final sudo = argResults!['sudo'] && await Executable('sudo').exists();

    // Move the file to the system bin directory.
    final moved = await moveToBin(file, sudo: sudo);

    // If the file could not be moved, display an error message and exit.
    if (moved == null) {
      out("{@red}Failed to move '${file.absolute.path}' to bin{@end}");
      exit(unableToOpenOutputFileForWriting);
    }

    // Get the final path of the moved file.
    final finalPath = moved.path;

    // Display a success message if verbose output is enabled.
    if (argResults!['verbose']) {
      out("{@green}File moved to bin: '$finalPath'{@end}");
    }

    // If the file should be marked as executable, mark it.
    if (argResults!['exec']) {
      final run = Run();
      final marked = await run.asExec(finalPath, sudo: sudo);

      // If the file could not be marked as executable, display an error message and exit.
      if (!marked) {
        out("{@red}Failed to mark '$finalPath' as executable{@end}");
        exit(cantExecute);
      }

      // Display a success message if verbose output is enabled.
      if (argResults!['verbose']) {
        out("{@green}File marked as executable: '$finalPath'{@end}");
      }
    }

    // Print the final path of the moved file and exit with a success code.
    print(finalPath);
    exit(success);
  }
}
