import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/xpm.dart';

class RefreshCommand extends Command {
  @override
  final name = "refresh";
  @override
  final aliases = ['ref'];
  @override
  final description = "Refresh the package list";
  @override
  final category = "For humans";

  // RefreshCommand() {

  // }

  // [run] may also return a Future.
  @override
  void run() async {
    if (argResults!.name == 'refresh') {
      final cacheDir = await XPM.cacheDir('');
      final tipFile = File('${cacheDir.path}/refresh_tip_shown');
      if (!tipFile.existsSync()) {
        Logger.tip('You can use the alias "ref" instead of "refresh"');
        tipFile.createSync();
      }
    }

    await Repositories.index();
  }
}
