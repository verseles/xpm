import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xpm/commands/devs/check.dart';
import 'package:xpm/commands/devs/get.dart';
import 'package:xpm/commands/devs/make.dart';
import 'package:xpm/commands/devs/repo/repo.dart';
import 'package:xpm/commands/humans/install.dart';
import 'package:xpm/commands/humans/refresh.dart';
import 'package:xpm/commands/humans/remove.dart';
import 'package:xpm/commands/humans/search.dart';
import 'package:xpm/commands/humans/update.dart';
import 'package:xpm/commands/humans/upgrade.dart';

void main(List<String> args) {
  CommandRunner('xpm', 'Universal package manager for any unix-like distro')
    ..addCommand(RefreshCommand())
    ..addCommand(SearchCommand())
    ..addCommand(InstallCommand())
    ..addCommand(UpdateCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(UpgradeCommand())
    ..addCommand(MakeCommand())
    ..addCommand(CheckCommand())
    ..addCommand(RepoCommand())
    ..addCommand(GetCommand())
    ..run(args).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // usage error.
    });
}
