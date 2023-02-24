import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/pubspec.dart' as pubspec;

class XPM {
  static String get name => pubspec.name;

  static String get version => pubspec.version;

  static String get description => pubspec.description.split('.').first;

  static get installMethods => {
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
  /// There is no need to cache the result as it is cached by the [Executable] class.
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

    String gitPath = (await git.find(cache: false))!;
    if (arguments != null) {
      // leave(message: '$gitPath ${arguments.join(" ")}');
      await runExecutableArguments(gitPath, arguments, verbose: false);
    }

    return git;
  }

  static String? _getEnv(String name, {String defaultValue = ''}) {
    return Platform.environment[name] ?? defaultValue;
  }

  static Future<Directory> cacheDir(String? path) async {
    final String cacheBasePath =
        _getEnv('XDG_CACHE_HOME') ?? '$userHomePath/.cache';
    return Directory('$cacheBasePath/$name/$path').create(recursive: true);
  }

  /// Returns the path to the bash executable.
  static String? _bash;
  static Future<String> get bash async {
    if (_bash != null) {
      return _bash!;
    }
    final bash = Executable('bash');
    if (!await bash.exists()) {
      throw Exception("Bash is not installed.");
    }

    _bash = (await bash.find())!;
    return _bash!;
  }

  /// Returns data directory.
  static Future<Directory> dataDir(String? path) async {
    final dir = Directory("$userHome/.$name/$path");
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

  static Directory? _userHome;

  /// Returns the path to the user's home directory.
  static Directory get userHome {
    if (_userHome != null) {
      return _userHome!;
    }
    String dirPath;
    dirPath = _getEnv('HOME') ??
        _getEnv('USERPROFILE') ??
        _getEnv('HOMEPATH') ??
        Directory('.').resolveSymbolicLinksSync();
    _userHome = Directory(dirPath);
    return _userHome!;
  }
}
