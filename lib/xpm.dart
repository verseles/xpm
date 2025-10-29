import 'dart:io';

import 'package:process_run/cmd_run.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/pubspec.dart' as pubspec;

/// A class that provides utility methods for XPM.
class XPM {
  /// Returns the name of the package.
  static String get name => pubspec.name;

  /// Returns the version of the package.
  static String get version => pubspec.version;

  /// Returns the description of the package.
  static String get description => pubspec.description.split('.').first;

  static Map<String, String> get installMethods => {
    'auto': 'Automatically choose the best method or fallsback to [any].',
    'any': 'Use the generic method. Sometimes this is the best method.',
    'apt': 'Use apt or apt-like package manager.',
    'flatpak': 'Use flatpak or flatpak-like package manager.',
    'snap': 'Use snap or snap-like package manager.',
    'appimage': 'Use compiled binaries if available.',
    'brew': 'Use brew or brew-like package manager.',
    'choco': 'Use choco or choco-like package manager.',
    'dnf': 'Use dnf or dnf-like package manager.',
    'pacman': 'Use pacman or pacman-like package manager.',
    'zypper': 'Use zypper or zypper-like package manager.',
    'termux': 'Use android or android-like package manager.',
    'swupd': 'Use swupd or swupd-like package manager.',
  };

  /// Returns a map of architecture correspondences.
  static Map<String, String> get archCorrespondence => {
    'linux64': 'linux-x86_64',
    'linux32': 'linux-i686',
    'linuxarm': 'linux-armv7l',
    'linuxarm64': 'linux-aarch64',
    'windows32': 'windows-i686',
    'win32': 'windows-i686',
    'win64': 'windows-x86_64',
    'macos64': 'darwin-x86_64',
    'macos-aarch64': 'macos-arm64',
    'freebsd32': 'freebsd-i686',
    'freebsd64': 'freebsd-x86_64',
    'netbsd32': 'netbsd-i686',
    'netbsd64': 'netbsd-x86_64',
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

  /// Returns the value of an environment variable.
  static String? _getEnv(String name, {String? defaultValue}) {
    return Platform.environment[name] ?? defaultValue;
  }

  /// Returns the cache directory.
  static Future<Directory> cacheDir(String? path) async {
    final String cacheBasePath = _getEnv('XDG_CACHE_HOME') ?? '${userHome.path}/.cache';
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

  /// Returns the data directory.
  static Future<Directory> dataDir(String? path) async {
    final dir = Directory("${userHome.path}/.$name/$path");
    return await dir.create(recursive: true);
  }

  /// Returns the system-wide temporary directory.
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
    dirPath = _getEnv('HOME') ?? _getEnv('USERPROFILE') ?? _getEnv('HOMEPATH') ?? Directory.current.absolute.path;
    _userHome = Directory(dirPath);
    return _userHome!;
  }
}
