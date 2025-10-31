import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/os/executable.dart';
import 'package:xpm/os/prepare.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/show_usage.dart';
import 'package:xpm/xpm.dart';
import 'package:xpm/database/models/package.dart';

/// A command that installs a package.
class InstallCommand extends Command {
  @override
  final name = 'install';

  @override
  String get invocation => '${runner!.executableName} $name <package>';

  @override
  final aliases = ['i'];

  @override
  final description = 'Install a package.';

  @override
  final category = 'For humans';

  InstallCommand() {
    // Add the method option.
    argParser.addOption(
      'method',
      abbr: 'm',
      help: 'The method to use to install the package.',
      valueHelp: 'auto',
      defaultsTo: 'auto',
      allowed: XPM.installMethods.keys,
      allowedHelp: XPM.installMethods,
    );

    // Add the force-method flag.
    argParser.addFlag(
      'force-method',
      negatable: false,
      help:
          'Force the selected method set by --method.'
          '\nIf not set, the selected method can fallback to another method or finally to [any].',
    );

    argParser.addOption('channel', abbr: 'c', help: 'Inform the prefered channel to install the package.');

    // Add the flags option.
    argParser.addMultiOption(
      'flags',
      abbr: 'e',
      help:
          'Inform custom flags to the script.'
          '\nUse this option multiple times to pass multiple flags.'
          '\nExample: --flags="--flag1" --flags="--flag2"',
    );

    // add verbose flag
    argParser.addFlag('verbose', negatable: false, help: 'Show more information about what is going on.');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    // Get the list of packages to install.
    List<String> packagesRequested = argResults!.rest;
    showUsage(packagesRequested.isEmpty, () => printUsage());

    // Get the Bash instance.
    final bash = await XPM.bash;

    // Get the local database instance.
    final db = await DB.instance();

    // Install each package.
    for (String packageRequested in packagesRequested) {
      final packageInDB = await db.packages.filter().nameEqualTo(packageRequested).findFirst();
      if (packageInDB == null) {
        leave(message: 'Package "{@gold}$packageRequested{@end}" not found.', exitCode: cantExecute);
      }

      var repo = packageInDB.repo.value!;
      final prepare = Prepare(repo, packageInDB, args: argResults);
      if (packageInDB.installed != null && Executable(packageRequested).existsSync(cache: false)) {
        Logger.info('Reinstalling "$packageRequested"...');
      } else {
        Logger.info('Installing "$packageRequested"...');
      }

      // Run the installation script.
      final runner = Run();
      try {
        await runner.simple(bash, ['-c', 'source ${await prepare.toInstall()}']);
      } on ShellException catch (e) {
        sharedStdIn.terminate();
        String error = 'Failed to install "$packageRequested"';
        if (argResults!['verbose'] == true) {
          error += ': ${e.message}';
        } else {
          error += '.';
        }

        leave(message: error, exitCode: e.result?.exitCode ?? generalError);
      }

      // Check if the package was installed successfully.
      final bashScript = BashScript(packageInDB.script);
      bool hasValidation = await bashScript.hasFunction('validate');
      String? error;
      if (hasValidation) {
        Logger.info('Checking installation of $packageRequested...');
        try {
          await runner.simple(bash, ['-c', 'source ${await prepare.toValidate()}']);
        } on ShellException catch (e) {
          error = 'Package "$packageRequested" installed with errors';
          if (argResults!['verbose'] == true) {
            error += ': ${e.message}';
          } else {
            error += '.';
          }
        }
      } else {
        Logger.warning('No validation found for $packageRequested.');
      }

      // Update the local database to reflect the installation.
      await db.writeTxn(() async {
        packageInDB.installed = packageInDB.version;
        packageInDB.method = argResults!['method'];
        packageInDB.channel = argResults!['channel'];
        await db.packages.put(packageInDB);
      });

      // Log the result of the installation.
      if (error != null) {
        Logger.error(error);
      } else {
        Logger.success('Successfully installed "$packageRequested".');
      }
    }
    sharedStdIn.terminate();
  }
}
