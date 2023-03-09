import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/repo.dart';
import 'package:xpm/os/repositories.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';
import 'package:xpm/utils/slugify.dart';
import 'package:xpm/xpm.dart';

class RepoRemoveCommand extends Command {
  @override
  final name = "remove";
  @override
  String get invocation =>
      '${runner!.executableName} repo $name <repository url>';
  @override
  final aliases = ['rm', 'r'];
  @override
  final description = "Remove git repository from the list of repositories";

  RepoRemoveCommand() {
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    List<String> args = argResults!.rest;

    showUsage(args.isEmpty, () => printUsage());

    final remote = args[0];
    final slug = remote.slugify();
    final localDirectory = await Repositories.dir(slug, create: false);

    // @LOG Removing this repo to the list of repos

    if (await XPM.isGit(localDirectory)) {
      await localDirectory.delete(recursive: true);
    }

    final db = await DB.instance();

    await db.writeTxn(() async {
      return await db.repos.where().urlEqualTo(remote).deleteAll();
    });

    out("{@green}Repo removed from the list of repos{@end}");
  }
}
