import 'dart:io';

import 'package:process_run/shell.dart';
import 'package:xpm/xpm.dart';

class Run {
  /// Run a command on the system
  /// If [sudo] is true, the command will be run with sudo permissions
  /// If [onProgress] is provided, it will be called with the output of the
  /// command
  Future<ProcessResult> simple(
    String script,
    List<String> args, {
    void Function(String)? onProgress,
    bool quiet = false,
    bool sudo = false,
  }) async {
    final controller = ShellLinesController();
    ShellEnvironment env = ShellEnvironment()..aliases['sudo'] = 'sudo --stdin';
    Shell shell = Shell(
      stdout: controller.sink,
      environment: env,
      workingDirectory: XPM.userHome.path,
      runInShell: true,
      commandVerbose: false,
    );

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
        return true;
      } else {
        List<String> args = ['-c', 'echo "$text" > $filePath'];
        final result = await simple('sh', args, sudo: sudo);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Create an empty file at [filePath]
  /// If [sudo] is true, the file will be created with sudo permissions
  Future<bool> touch(String filePath, {sudo = false}) async {
    try {
      if (Platform.isWindows) {
        await File(filePath).create();
        return true;
      } else {
        final result = await simple('touch', [filePath], sudo: sudo);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// give [filePath] executable permissions
  /// If [sudo] is true, the file will be given executable permissions with sudo
  Future<bool> asExec(String filePath, {bool sudo = false}) async {
    try {
      if (Platform.isWindows) {
        return true;
      } else {
        final result = await simple('chmod', ['+x', filePath], sudo: sudo);
        if (result.exitCode != 0) {
          return false;
        }
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
  Future<bool> delete(
    String filePath, {
    sudo = false,
    recursive = false,
    force = false,
  }) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      return true;
    }
    try {
      if (Platform.isWindows) {
        await file.delete();
        return true;
      } else {
        List<String> args = ['-f', filePath];
        if (recursive) {
          args.insert(0, '-r');
        }
        if (force) {
          args.insert(0, '-f');
        }
        final result = await simple('rm', args, sudo: sudo);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Rename or move [oldPath] to [newPath]
  /// If [sudo] is true, the file will be moved with sudo permissions
  Future<bool> move(
    String $oldPath,
    String $newPath, {
    sudo = false,
    force = false,
    recursive = false,
    preserve = false,
  }) async {
    try {
      if (Platform.isWindows) {
        await File($oldPath).rename($newPath);
        return true;
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
        final result = await simple('mv', args, sudo: sudo);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Copy [oldPath] to [newPath]
  /// If [sudo] is true, the file will be copied with sudo permissions
  /// If [recursive] is true, the file will be copied recursively
  /// If [force] is true, the file will be copied even if it already exists
  /// If [preserve] is true, the file will be copied preserving the original
  /// permissions
  Future<bool> copy(
    String oldPath,
    String newPath, {
    sudo = false,
    recursive = false,
    force = false,
    preserve = false,
  }) async {
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
        final result = await simple('cp', args, sudo: sudo);
        return result.exitCode == 0;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if [filePath] exists
  /// If [sudo] is true, the file will be checked with sudo permissions
  Future<bool> exists(String filePath, {sudo = false}) async {
    try {
      if (Platform.isWindows) {
        return await File(filePath).exists();
      }

      final result = await simple('test', ['-e', filePath], sudo: sudo);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
