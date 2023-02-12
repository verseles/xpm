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
    if (Platform.isWindows) {
      await File(filePath).writeAsString(text);
      return;
    }
    List<String> args = ['-c', 'echo "$text" > $filePath'];
    await simple('sh', args, sudo: sudo);
  }

  // touch file
  Future<void> touch(String filePath, {sudo = false}) async {
    if (Platform.isWindows) {
      await File(filePath).create();
    }
    await simple('touch', [filePath], sudo: sudo);
  }

  // give file executable permissions
  Future<void> asExec(String filePath, {sudo = false}) async {
    if (Platform.isWindows) {
      return;
    }
    await simple('chmod', ['+x', filePath], sudo: sudo);
  }

  // Delete file
  Future<void> delete(String filePath, {sudo = false}) async {
    if (Platform.isWindows) {
      await File(filePath).delete();
      return;
    }

    await simple('rm', ['-f', filePath], sudo: sudo);
  }

  // Check if file exists
  Future<bool> exists(String filePath, {sudo = false}) async {
    if (Platform.isWindows) {
      return await File(filePath).exists();
    }

    try {
      await simple('test', ['-e', filePath], sudo: sudo);
      return true;
    } catch (e) {
      return false;
    }
  }
}
