import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/prepare.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/debug.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/logger.dart';
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
        defaultsTo: 'auto',
        allowed: XPM.installMethods.keys,
        allowedHelp: XPM.installMethods);

    argParser.addFlag('force-method',
        negatable: false,
        help: 'Force the selected method set by --method.'
            '\nIf not set, the selected method can fallsback to another method or finally to [any].');

    argParser.addOption('channel',
        abbr: 'c', help: 'Inform the prefered channel to install the package.');

    argParser.addMultiOption('flags',
        abbr: 'f',
        help: 'Inform custom flags to the script.'
            '\nUse this option multiple times to pass multiple flags.'
            '\nExample: --flags="--flag1" --flags="--flag2"');

    // add verbose flag
    argParser.addFlag('verbose',
        negatable: false,
        help: 'Show more information about what is going on.');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> packagesRequested = argResults!.rest;

    showUsage(packagesRequested.isEmpty, () => printUsage());

    final bash = await XPM.bash;

    final db = await DB.instance();
    for (String packageRequested in packagesRequested) {
      final packageInDB =
          await db.packages.filter().nameEqualTo(packageRequested).findFirst();
      if (packageInDB == null) {
        leave(
            message: 'Package "{@gold}$packageRequested{@end}" not found.',
            exitCode: cantExecute);
      }

      var repoRemote = packageInDB.repo.value!.url;
      final prepare = Prepare(repoRemote, packageRequested, args: argResults);
      if (packageInDB.installed != null &&
          Executable(packageRequested).existsSync(cache: false)) {
        Logger.info('Reinstalling "$packageRequested"...');
      } else {
        Logger.info('Installing "$packageRequested"...');
      }

      final runner = Run();
      try {
        await runner
            .simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
      } on ShellException catch (_) {
        sharedStdIn.terminate();
        String error = 'Failed to install "$packageRequested"';
        if (argResults!['verbose'] == true) {
          error += ': ${_.message}';
        } else {
          error += '.';
        }

        leave(message: error, exitCode: _.result?.exitCode ?? generalError);
      }

      final bashScript = BashScript(packageInDB.script);
      bool hasValidation = await bashScript.hasFunction('validate');
      String? error;
      if (hasValidation) {
        Logger.info('Checking installation of $packageRequested...');
        try {
          await runner
              .simple(bash, ['-c', 'source ${await prepare.toValidate()}']);
        } on ShellException catch (_) {
          error = 'Package "$packageRequested" installed with errors';
          if (argResults!['verbose'] == true) {
            error += ': ${_.message}';
          } else {
            error += '.';
          }
        }
      }

      sharedStdIn.terminate();

      await db.writeTxn(() async {
        packageInDB.installed = packageInDB.version;
        await db.packages.put(packageInDB);
      });

      if (error != null) {
        Logger.error(error);
      } else {
        Logger.success('Successfully installed "$packageRequested".');
      }
    }
  }
}
