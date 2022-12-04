import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/run.dart';

class XPM {
  static String get name => "xpm";

  static final installMethods = {
    'auto': 'Automatically choose the best method or fallsback to [any].',
    'any': 'Use the generic method. Sometimes this is the best method.',
    'apt': 'Use apt or apt-like package manager.',
    'pack': 'Use snap, flatpak or appimage.',
    'brew': 'Use brew or brew-like package manager.',
    'choco': 'Use choco or choco-like package manager.',
    'dnf': 'Use dnf or dnf-like package manager.',
    'pacman': 'Use pacman or pacman-like package manager.',
    'yum': 'Use yum or yum-like package manager.',
    'zypper': 'Use zypper or zypper-like package manager.',
  };

  /// Returns the path to the git executable.
  /// @TODO cache this.
  static Future<Executable> git([List<String>? arguments]) async {
    final git = Executable('git');
    if (!await git.exists()) {
      final pkcon = Executable('pkcon');
      if (await pkcon.exists()) {
        print('Installing git...');
        final String pkconPath = (await pkcon.find())!;
        final installer = Run();
        await installer.simple(pkconPath, ['install', '-y', 'git']);
      }
    }
    if (!await git.exists()) {
      throw Exception('Git is not installed and I failed to install it.');
    }

    String gitPath = (await git.find())!;
    if (arguments != null) {
      await runExecutableArguments(gitPath, arguments, verbose: true);
    }

    return git;
  }

  static String? _getEnv(String name) {
    return Platform.environment[name];
  }

  static Future<Directory> cacheDir(String? path) async {
    final String cacheBasePath = _getEnv('XDG_CACHE_HOME') ?? '$userHomePath/.cache';
    return Directory('$cacheBasePath/$name/$path').create(recursive: true);
  }

  /// Returns the path to the bash executable.
  /// @TODO cache this.
  static Future<String> bash() async {
    final bash = Executable('bash');
    if (!await bash.exists()) {
      throw Exception("Bash is not installed.");
    }
    String bashPath = (await bash.find())!;

    return bashPath;
  }

  /// Returns data directory.
  /// @TODO change working directory
  static Future<Directory> dataDir(String? path) async {
    final dir = Directory("$userHomePath/.$name/$path");
    return await dir.create(recursive: true);
  }

  /// Returns system-wide temporary directory
  static Future<Directory> temp(String? path) async {
    final tmpDir = Directory.systemTemp;
    final dir = Directory("${tmpDir.path}/$name/$path");
    return await dir.create(recursive: true);
  }

  /// Checks if the directory is a git repository.
  static Future<bool> isGit(Directory dir) async {
    final gitDir = Directory("${dir.path}/.git");
    return await gitDir.exists();
  }
}
