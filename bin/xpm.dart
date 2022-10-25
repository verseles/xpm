import 'dart:io';
import 'package:args/command_runner.dart';

import 'package:xpm/Commands/devs/check.dart';
import 'package:xpm/Commands/devs/make.dart';
import 'package:xpm/Commands/humans/install.dart';
import 'package:xpm/Commands/humans/remove.dart';
import 'package:xpm/Commands/humans/update.dart';
import 'package:xpm/Commands/humans/upgrade.dart';

void main(List<String> args) {
  CommandRunner('xpm', 'Universal package manager for any unix-like distro')
    ..addCommand(InstallCommand())
    ..addCommand(UpdateCommand())
    ..addCommand(RemoveCommand())
    ..addCommand(UpgradeCommand())
    ..addCommand(MakeCommand())
    ..addCommand(CheckCommand())
    ..run(args).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // usage error.
    });
}
