import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/slugify.dart';
import 'package:xpm/xpm.dart';

class RepoAddCommand extends Command {
  @override
  final name = "add";
  @override
  final aliases = ['radd'];
  @override
  final description = "Add a new git repository to the list of repositories";
  @override
  final category = "For developers";

  RepoAddCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> repo = argResults!.rest;

    if (repo.isEmpty) {
      printUsage();
      exit(64);
    }

    final remote = repo[0];
    final slug = remote.slugify();
    final localDirectory = await Repositories.dir(slug);
    final localPath = localDirectory.path;

    // @LOG Adding this repo to the list of repos

    if (await XPM.isGit(localDirectory)) {
      // @LOG This repo is already in the list of repos, refreshing it
      await XPM.git(['-C', localPath, 'pull']);
    } else {
      await XPM.git(['clone', remote, localPath]);
    }
  }
}
