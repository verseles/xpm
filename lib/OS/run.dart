import 'dart:io';

import 'package:process_run/shell.dart';

class Run {
  Future<ProcessResult> simple(script, List<String> args) async {
    var controller = ShellLinesController();
    ShellEnvironment env = ShellEnvironment()..aliases['sudo'] = 'sudo --stdin';
    Shell shell = Shell(
        stdout: controller.sink,
        stdin: sharedStdIn,
        environment: env,
        workingDirectory: userHomePath,
        runInShell: true,
        commandVerbose: false);

    controller.stream.listen((event) {
      print('--- $event');
    });

    return await shell.runExecutableArguments(script, args);
  }
}
