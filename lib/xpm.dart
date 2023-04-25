import 'dart:io';

import 'package:process_run/cmd_run.dart';
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
        'zypper': 'Use zypper or zypper-like package manager.',
        'android': 'Use android or android-like package manager.',
        'swupd': 'Use swupd or swupd-like package manager.'
      };

  static get archCorrespondence => {
        'linux64': 'linux-x86_64',
        'linux32': 'linux-i686',
        'linuxarm': 'linux-armv7l',
        'linuxarm64': 'linux-aarch64',
        'macos': 'darwin-x86_64',
        'windows': 'windows-x86_64',
        'windows32': 'windows-i686',
        'win32': 'windows-i686',
        'win64': 'windows-x86_64',
        'macos64': 'darwin-x86_64',
        'macos-arm64': 'darwin-aarch64',
        'macos-arm': 'darwin-armv7l',
        'freebsd32': 'freebsd-i686',
        'freebsd64': 'freebsd-x86_64',
        'netbsd32': 'netbsd-i686',
        'netbsd64': 'netbsd-x86_64',
        'openbsd': 'openbsd-x86_64',
        'openbsd32': 'openbsd-i686',
        'openbsd64': 'openbsd-x86_64',
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
      await runExecutableArguments(gitPath, arguments, verbose: false);
    }

    return git;
  }

  static String? _getEnv(String name, {String? defaultValue}) {
    return Platform.environment[name] ?? defaultValue;
  }

  static Future<Directory> cacheDir(String? path) async {
    final String cacheBasePath =
        _getEnv('XDG_CACHE_HOME') ?? '${userHome.path}/.cache';
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
    final dir = Directory("${userHome.path}/.$name/$path");
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
        Directory.current.absolute.path;
    _userHome = Directory(dirPath);
    return _userHome!;
  }
}
