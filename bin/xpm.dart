import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:args/command_runner.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:xpm/commands/devs/check.dart';
import 'package:xpm/commands/devs/checksum.dart';
import 'package:xpm/commands/devs/file/file.dart';
import 'package:xpm/commands/devs/get.dart';
import 'package:xpm/commands/devs/log.dart';
import 'package:xpm/commands/devs/make.dart';
import 'package:xpm/commands/devs/repo/repo.dart';
import 'package:xpm/commands/devs/shortcut.dart';
import 'package:xpm/commands/humans/install.dart';
import 'package:xpm/commands/humans/refresh.dart';
import 'package:xpm/commands/humans/remove.dart';
import 'package:xpm/commands/humans/search.dart';
import 'package:xpm/commands/humans/upgrade.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/setting.dart';
import 'package:xpm/utils/leave.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/xpm.dart';
import 'package:xpm/utils/version_checker.dart';

void main(List<String> args) async {
  if (args.isNotEmpty && (args.first == '-v' || args.first == '--version')) {
    showVersion(args);
  }

  final bool isRepoOutdated =
      await Setting.get('needs_refresh', defaultValue: true);
  if (!isRepoOutdated) {
    // @VERBOSE
    await Repositories.index();
  }

  final bool isXPMOutdated =
      await Setting.get('needs_uptade', defaultValue: true);
  if (!isXPMOutdated) {
    // @VERBOSE
    final fourDays = DateTime.now().add(Duration(days: 4));
    final newVersionAvailable = await VersionChecker()
        .checkForNewVersion(XPM.name, Version.parse(XPM.version));
    Setting.set('needs_uptade', true, expires: fourDays, lazy: true);
    if (newVersionAvailable != null) {
      Logger.info('There is a new version available: $newVersionAvailable');
      Logger.info('Run: {@green}xpm install xpm{@end} to update.');
    }
  }
  await Setting.deleteExpired(lazy: true);

  final runner = CommandRunner(XPM.name, XPM.description)
    ..argParser.addFlag('version',
        abbr: 'v', negatable: false, help: 'Prints the version of ${XPM.name}.')
    ..addCommand(RefreshCommand())
    ..addCommand(SearchCommand())
    ..addCommand(InstallCommand())
    ..addCommand(UpgradeCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(MakeCommand())
    ..addCommand(CheckCommand())
    ..addCommand(RepoCommand())
    ..addCommand(FileCommand())
    ..addCommand(GetCommand())
    ..addCommand(ShortcutCommand())
    ..addCommand(ChecksumCommand())
    ..addCommand(LogCommand());

  runner.run(args).catchError((error) async {
    if (error is! UsageException) throw error;
    // Use SearchCommand as default command
    // only runs if no elements on args starts with '-'
    if (error.message.startsWith('Could not find a command named')) {
      await runner.run({'search', ...args});
      exit(success);
    }

    print(error);
    Logger.tip('To search packages use: {@cyan}${XPM.name} <package name>');

    exit(wrongUsage);
  });
}

Never showVersion(args) {
  if (args.first == '-v') {
    leave(message: XPM.version, exitCode: success);
  }
  leave(
      message: '${XPM.name} v${XPM.version} - ${XPM.description}',
      exitCode: success);
}
