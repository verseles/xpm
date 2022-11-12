import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/OS/prepare.dart';
import 'package:xpm/OS/repositories.dart';
import 'package:xpm/OS/run.dart';
import 'package:xpm/xpm.dart';

class InstallCommand extends Command {
  @override
  final name = 'install';

  @override
  String get invocation => '${runner!.executableName} $name <package>';
  @override
  final aliases = ['i'];
  @override
  final description = 'Install a package';
  @override
  final category = 'For humans';

  InstallCommand() {
    /// @FIXME convert this list to a Map<String, String> and use it to generate the help.
    argParser.addOption('prefer', help: 'The method to use to install the package.', valueHelp: 'auto', allowed: [
      'auto',
      'any',
      'apt',
      'snap',
      'appimage',
      'flatpak',
      'brew',
      'choco',
      'dnf',
      'pacman',
      'yum',
      'zypper',
    ], allowedHelp: {
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
    });
    argParser.addFlag('force-prefer',
        negatable: false,
        help: 'Force the selected method set by --prefer.'
            '\nIf not set, the selected method can fallsback to another method or finally to [any].');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> packages = argResults!.rest;

    if (packages.isEmpty) {
      printUsage();
      exit(64);
    } else {
      // @FIXME find repo
      Directory repoDir = await Repositories.dir('xpm-popular');

      final bash = await XPM.bash();

      for (String package in packages) {
        // @TODO Find package or warn then continue
        // @TODO Check if package is already installed
        final prepare = Prepare('xpm-popular', package, args: argResults);
        print('Installing $package...');

        final runner = Run();
        try {
          await runner.simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
        } on ShellException catch (_) {
          print('Failed to install $package: ${_.message}');
          exit(_.result?.exitCode ?? 1);
        }

        print('Checking installation of $package...');
        try {
          await runner.simple(bash, ['-c', 'source ${await prepare.toValidate()}']);
        } on ShellException catch (_) {
          print('$package installed with errors: $package: ${_.message}');
          exit(_.result?.exitCode ?? 1);
        }

        print('Successfully installed $package.');
        await sharedStdIn.terminate();
      }
    }
  }
}
