import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/setting.dart';
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
      final cacheName = 'tip_refresh_ref_shown';
      await Setting.delete(cacheName);

      final bool shown = await Setting.get(cacheName, defaultValue: false);
      if (!shown) {
        final tip = 'You can use the alias "ref" instead of "refresh"';
        Logger.tip(tip);
        final nextWeek = DateTime.now().add(Duration(days: 7));
        await Setting.set(cacheName, true, expires: nextWeek);
      }
    }

    await Repositories.index();
  }
}
