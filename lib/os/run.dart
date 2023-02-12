import 'dart:io';

import 'package:process_run/shell.dart';

class Run {
  Future<ProcessResult> simple(script, List<String> args,
      {void Function(String)? onProgress, quiet = false, sudo = false}) async {
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

    if (sudo) {
      return await shell.runExecutableArguments('sudo', [script, ...args]);
    } else {
      return await shell.runExecutableArguments(script, args);
    }
  }

  Future<void> writeToFile(String filePath, String text, {sudo = false}) async {
    List<String> args = ['-c', 'echo "$text" > $filePath'];
    await simple('sh', args, sudo: sudo);
  }
}
