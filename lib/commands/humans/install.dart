import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/os/prepare.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/out.dart';
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
            exitCode: cantExecute);
      }
      var repoRemote = packageInDB.repo.value!.url;
      // @TODO Check if package is already installed
      final prepare = Prepare(repoRemote, packageRequested, args: argResults);
      out('Installing "{@blue}$packageRequested{@end}"...');

      final runner = Run();
      try {
        await runner
            .simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
      } on ShellException catch (_) {
        sharedStdIn.terminate();
        String error = 'Failed to install "{@blue}$packageRequested{@end}"';
        if (argResults!['verbose'] == true) {
          error += ': ${_.message}';
        } else {
          error += '.';
        }

        leave(message: error, exitCode: _.result?.exitCode ?? generalError);
      }

      print('Checking installation of $packageRequested...');
      try {
        await runner
            .simple(bash, ['-c', 'source ${await prepare.toValidate()}']);
      } on ShellException catch (_) {
        sharedStdIn.terminate();
        String error =
            'Package "{@blue}$packageRequested{@end}" installed with errors';
        if (argResults!['verbose'] == true) {
          error += ': ${_.message}';
        } else {
          error += '.';
        }

        leave(message: error, exitCode: _.result?.exitCode ?? generalError);
      }

      sharedStdIn.terminate();

      await db.writeTxn(() async {
        packageInDB.installed = true;
        await db.packages.put(packageInDB);
      });

      out('Successfully installed "{@blue}$packageRequested{@end}".');
    }
  }
}
