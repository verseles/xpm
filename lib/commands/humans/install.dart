import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/os/prepare.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/show_usage.dart';
import 'package:xpm/xpm.dart';
import 'package:xpm/database/models/package.dart';

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
    argParser.addFlag('verbose',
        negatable: false,
        abbr: 'v',
        help: 'Show more information about what is going on.');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> packagesRequested = argResults!.rest;

    showUsage(packagesRequested.isEmpty, () => printUsage());

    final bash = await XPM.bash();

    final db = await DB.instance();
    for (String packageRequested in packagesRequested) {
      final packageInDB =
          await db.packages.filter().nameEqualTo(packageRequested).findFirst();
      if (packageInDB == null) {
        leave(
            message: 'Package "{@blue}$packageRequested{@end}" not found.',
            exitCode: 126);
      }
      var repoRemote = packageInDB.repo.value!.url;
      // @TODO Check if package is already installed
      final prepare =
          await Prepare(repoRemote, packageRequested, args: argResults);
      print('Installing $packageRequested...');

      final runner = Run();
      try {
        await runner
            .simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
      } on ShellException catch (_) {
        leave(
            message:
                'Failed to install "{@blue}$packageRequested{@end}": ${_.message}',
            exitCode: _.result?.exitCode ?? 1);
      }

      print('Checking installation of $packageRequested...');
      try {
        await runner
            .simple(bash, ['-c', 'source ${await prepare.toValidate()}']);
      } on ShellException catch (_) {
        print(
            '$packageRequested installed with errors: $packageRequested: ${_.message}');
        exit(_.result?.exitCode ?? 1);
      }

      print('Successfully installed $packageRequested.');
      await sharedStdIn.terminate();
    }
  }
}
