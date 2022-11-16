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
    argParser.addOption('method',
        abbr: 'm',
        help: 'The method to use to install the package.',
        valueHelp: 'auto',
        allowed: XPM.installMethods.keys,
        allowedHelp: XPM.installMethods);

    argParser.addFlag('force-method',
        negatable: false,
        help: 'Force the selected method set by --prefer.'
            '\nIf not set, the selected method can fallsback to another method or finally to [any].');

    // add verbose flag
    argParser.addFlag('verbose', negatable: false, abbr: 'v', help: 'Show more information about what is going on.');
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
