import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/delete_from_bin.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that deletes a file from the system bin directory.
class FileUnbinCommand extends Command {
  @override
  final name = "unbin";
  @override
  String get invocation => '${runner!.executableName} file $name <file path>';
  @override
  final description = "Deletes a file from the system bin directory";

  /// Creates a new instance of the [FileUnbinCommand] class.
  FileUnbinCommand() {
    argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: true,
      defaultsTo: true,
      help: 'Verbose output',
    );
    argParser.addFlag('sudo', abbr: 's', negatable: false, help: 'Run as sudo');
    argParser.addFlag(
      'force',
      abbr: 'f',
      negatable: false,
      help: 'Force delete',
    );
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.isEmpty, () => printUsage());

    final filePath = args[0];

    final file = File(filePath);
    final finalPath = file.absolute.path;

    final deleted = await deleteFromBin(
      file,
      sudo: argResults!['sudo'],
      force: argResults!['force'],
    );

    if (!deleted) {
      out("{@red}Failed to delete '$filePath'{@end}");
      exit(unableToOpenOutputFileForWriting);
    }

    if (argResults!['verbose']) {
      out("{@green}File removed from bin: '$finalPath'{@end}");
    }

    print(finalPath);
    exit(success);
  }
}
