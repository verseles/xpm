import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:process_run/shell.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/os/prepare.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';
import 'package:xpm/xpm.dart';

/// A command that removes a package.
class RemoveCommand extends Command {
  @override
  final name = "remove";

  @override
  final aliases = ['rm', 'uninstall', 'un', 'r'];

  @override
  final description = "Removes a package";

  @override
  final category = "For humans";

  RemoveCommand() {
    // Add options and flags for the command.
    argParser.addOption(
      'method',
      abbr: 'm',
      help: 'The method to use to remove the package.',
      valueHelp: 'auto',
      allowed: XPM.installMethods.keys,
      allowedHelp: XPM.installMethods,
    );

    argParser.addFlag(
      'force-method',
      negatable: false,
      help:
          'Force the selected method set by --method.'
          '\nIf not set, the selected method can fallsback to another method or finally to [any].',
    );

    argParser.addOption('channel', abbr: 'c', help: 'Inform the prefered channel to install the package.');

    argParser.addFlag(
      'force',
      negatable: false,
      abbr: 'f',
      help: 'Force the removal of the package even if it is not installed.',
    );

    argParser.addMultiOption(
      'flags',
      abbr: 'e',
      help:
          'Inform custom flags to the script.'
          '\nUse this option multiple times to pass multiple flags.'
          '\nExample: --flags="--flag1" --flags="--flag2"',
    );

    argParser.addFlag('verbose', negatable: false, abbr: 'v', help: 'Show more information about what is going on.');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    // Get the list of packages to remove.
    List<String> packagesRequested = argResults!.rest;

    showUsage(packagesRequested.isEmpty, () => printUsage());

    // Get the Bash instance.
    final bash = await XPM.bash;

    // Get the local database instance.
    final db = await DB.instance();

    // Remove each package.
    for (String packageRequested in packagesRequested) {
      // Find the package in the local database.
      final packageInDB = await db.packages.filter().nameEqualTo(packageRequested).findFirst();
      if (packageInDB == null) {
        leave(message: 'Package "{@gold}$packageRequested{@end}" not found.', exitCode: cantExecute);
      }

      if (packageInDB.installed == null && !argResults!['force']) {
        // Check if the package is installed in the system but not for me.
        leave(message: 'Package "{@gold}$packageRequested{@end}" is not installed.', exitCode: cantExecute);
      }

      var repo = packageInDB.repo.value!;

      final prepare = Prepare(repo, packageInDB, args: argResults);
      out('Removing "{@blue}$packageRequested{@end}"...');

      // Run the removal script.
      final runner = Run();
      try {
        await runner.simple(bash, ['-c', 'source ${await prepare.toRemove()}']);
      } on ShellException catch (e) {
        sharedStdIn.terminate();

        String error = 'Failed to remove "{@red}$packageRequested{@end}"';
        if (argResults!['verbose'] == true) {
          error += ': ${e.message}';
        } else {
          error += '.';
        }

        leave(message: error, exitCode: e.result?.exitCode ?? generalError);
      }

      // Validate the removal of the package.
      try {
        await runner.simple(bash, ['-c', 'source ${await prepare.toValidate(removing: true)}']);
        String error = 'Failed to validate uninstall of "{@red}$packageRequested{@end}"';
        Logger.warning(error);
      } on ShellException {
        // If the package is not installed, the validation should pass
      }
      // Update the local database to reflect the removal.
      await db.writeTxn(() async {
        packageInDB.installed = null;
        packageInDB.method = null;
        packageInDB.channel = null;
        await db.packages.put(packageInDB);
      });

      // Log the result of the removal.
      Logger.success('Successfully removed "$packageRequested".');
    }
    sharedStdIn.terminate();
  }
}
