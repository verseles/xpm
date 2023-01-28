import 'dart:io';

import 'package:process_run/shell.dart';

class Run {
  Future<ProcessResult> simple(script, List<String> args,
      {void Function(String)? onProgress, quiet = false}) async {
    final controller = ShellLinesController();
    ShellEnvironment env = ShellEnvironment()..aliases['sudo'] = 'sudo --stdin';
    Shell shell = Shell(
        stdout: controller.sink,
        stdin: sharedStdIn,
        environment: env,
        workingDirectory: userHomePath,
        runInShell: true,
        commandVerbose: false);

    if (onProgress != null) {
      controller.stream.listen((line) => onProgress.call(line));
    } else if (!quiet) {
      controller.stream.listen((line) => print('-> $line'));
    }

    return await shell.runExecutableArguments(script, args);
  }
}
