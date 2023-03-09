import 'dart:io';

import 'package:process_run/shell.dart';

class Run {
  /// Run a command on the system
  /// If [sudo] is true, the command will be run with sudo permissions
  /// If [onProgress] is provided, it will be called with the output of the
  /// command
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

  /// Write [text] to [filePath]
  /// If [sudo] is true, the file will be written with sudo permissions
  Future<bool> writeToFile(String filePath, String text, {sudo = false}) async {
    try {
      if (Platform.isWindows) {
        await File(filePath).writeAsString(text);
      } else {
        List<String> args = ['-c', 'echo "$text" > $filePath'];
        await simple('sh', args, sudo: sudo);
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  /// Create an empty file at [filePath]
  /// If [sudo] is true, the file will be created with sudo permissions
  Future<bool> touch(String filePath, {sudo = false}) async {
    try {
      if (Platform.isWindows) {
        await File(filePath).create();
      } else {
        await simple('touch', [filePath], sudo: sudo);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  /// give [filePath] executable permissions
  /// If [sudo] is true, the file will be given executable permissions with sudo
  Future<bool> asExec(String filePath, {bool sudo = false}) async {
    try {
      if (Platform.isWindows) {
        return true;
      } else {
        await simple('chmod', ['+x', filePath], sudo: sudo);
      }
    } catch (e) {
      return false;
    }

    final file = File(filePath);

    return file.existsSync() && file.statSync().modeString().contains('x');
  }

  /// Delete [filePath]
  /// If [sudo] is true, the file will be deleted with sudo permissions
  /// If [recursive] is true, the file will be deleted recursively
  /// If [force] is true, the file will be deleted even if it is read-only
  Future<bool> delete(String filePath,
      {sudo = false, recursive = false, force = false}) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      return true;
    }
    try {
      if (Platform.isWindows) {
        await file.delete();
      } else {
        List<String> args = ['-f', filePath];
        if (recursive) {
          args.insert(0, '-r');
        }
        if (force) {
          args.insert(0, '-f');
        }
        await simple('rm', args, sudo: sudo);
      }
    } catch (e) {
      return false;
    }
    final exists = await file.exists();
    return !exists;
  }

  /// Rename or move [oldPath] to [newPath]
  /// If [sudo] is true, the file will be moved with sudo permissions
  Future<bool> move(String $oldPath, String $newPath,
      {sudo = false,
      force = false,
      recursive = false,
      preserve = false}) async {
    try {
      if (Platform.isWindows) {
        await File($oldPath).rename($newPath);
      } else {
        List<String> args = [$oldPath, $newPath];
        if (recursive) {
          args.insert(0, '-r');
        }
        if (force) {
          args.insert(0, '-f');
        }
        if (preserve) {
          args.insert(0, '-p');
        }
        await simple('mv', args, sudo: sudo);
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  /// Copy [oldPath] to [newPath]
  /// If [sudo] is true, the file will be copied with sudo permissions
  /// If [recursive] is true, the file will be copied recursively
  /// If [force] is true, the file will be copied even if it already exists
  /// If [preserve] is true, the file will be copied preserving the original
  /// permissions
  Future<bool> copy(String oldPath, String newPath,
      {sudo = false,
      recursive = false,
      force = false,
      preserve = false}) async {
    try {
      if (Platform.isWindows) {
        await File(oldPath).copy(newPath);
        return true;
      } else {
        List<String> args = [oldPath, newPath];
        if (recursive) {
          args.insert(0, '-r');
        }
        if (force) {
          args.insert(0, '-f');
        }
        if (preserve) {
          args.insert(0, '-p');
        }
        await simple('cp', args, sudo: sudo);
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  /// Check if [filePath] exists
  /// If [sudo] is true, the file will be checked with sudo permissions
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
