import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that marks a file as executable.
class FileExecCommand extends Command {
  @override
  final name = "exec";

  @override
  final aliases = ['x'];

  @override
  String get invocation => '${runner!.executableName} file $name <file path>';

  @override
  final description = "Mark a file as executable";

  /// Creates a new instance of the [FileExecCommand] class.
  FileExecCommand() {
    argParser.addFlag('verbose',
        abbr: 'v', negatable: true, defaultsTo: true, help: 'Verbose output');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.isEmpty, () => printUsage());

    final filePath = args[0];

    final run = Run();
    final marked = await run.asExec(filePath);

    if (!marked) {
      out("{@red}Failed to mark '$filePath' as executable{@end}");
      exit(cantExecute);
    }

    if (argResults!['verbose']) {
      out("{@green}File marked as executable: '$filePath'{@end}");
    }

    print(File(filePath).absolute.path);
    exit(success);
  }
}

