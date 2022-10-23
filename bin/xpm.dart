import 'dart:io';

import 'package:args/command_runner.dart';

import 'package:xpm/Commands/install.dart';

void main(List<String> args) {
  CommandRunner('xpm', 'Universal package manager for any unix-like distro')
    ..addCommand(InstallCommand())
    ..addCommand(InstallCommand())
    ..addCommand(InstallCommand())
    ..run(args).catchError((error) {
      if (error is! UsageException) throw error;
      print(error);
      exit(64); // usage error.
    });
}
