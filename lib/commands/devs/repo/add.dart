import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/repo.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/slugify.dart';
import 'package:xpm/xpm.dart';

class RepoAddCommand extends Command {
  @override
  final name = "add";
  @override
  final aliases = ['a'];
  @override
  String get invocation => '${runner!.executableName} $name <repository url>';
  @override
  final description = "Add a new git repository to the list of repositories";

  RepoAddCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    if (args.isEmpty) {
      printUsage();
      exit(64);
    }

    final remote = args[0];
    final slug = remote.slugify();
    final localDirectory = await Repositories.dir(slug);
    final localPath = localDirectory.path;

    if (await XPM.isGit(localDirectory)) {
      out("{@yellow}This repo is already in the list of repos, refreshing it{@end}");
      await XPM.git(['-C', localPath, 'pull']);
    } else {
      await XPM.git(['clone', remote, localPath]);
    }

    final db = await DB.instance();
    final repo = Repo()..url = remote;

    await db.writeTxn(() async => await db.repos.putByUrl(repo));

    out("{@green}Repo added to the list of repos{@end}");
  }
}
