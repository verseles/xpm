import 'dart:io';
import 'package:console/console.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slug/slug.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/slugify.dart';

import 'package:xpm/xpm.dart';

class Repositories {
  /// Returns working directory
  static final Map<String, Future<Directory>> __dirs = {};

  static Future<Directory> dir(String? repo,
      {package = '', create = true}) async {
    final reposDir = await getReposDir();

    final dir = Directory("${reposDir.path}/$repo/$package");
    if (create) {
      return dir.create(recursive: true);
    }

    return dir;
  }

  static Future<Directory> getReposDir() async =>
      __dirs.putIfAbsent('reposDir', () async => (await XPM.dataDir('repos')));

  static void addRepo(String remote) async {
    final localDirectory = await dir(remote.slugify());
    final localPath = localDirectory.path;

    if (await XPM.isGit(localDirectory)) {
      await XPM.git(['-C', localPath, 'pull']);
    } else {
      await XPM.git(['clone', remote, localPath]);
    }

    final db = await DB.instance();
    final repo = Repo()..url = remote;

    await db.writeTxn(() async => await db.repos.putByUrl(repo));
  }

  static Future<List<Repo>> allRepos() async {
    final db = await DB.instance();
    final repos = await db.repos.where().findAll();
    return repos;
  }

  static void addPopular() async {
    final remote = 'https://github.com/verseles/xpm-popular.git';

    addRepo(remote);
  }

  static String repoName(String url) {
    final parts = url.split('/');
    if (parts.length < 2) {
      return 'unknown';
    }
    return parts.sublist(parts.length - 2).join('/').replaceAll('.git', '');
  }

  // Pull or clone all repos
  static pull() async {
    final Slug loader = Slug(slugStyle: SlugStyle.toggle);
    final repos = await allRepos();

    if (repos.isEmpty) {
      addPopular();
    }

    out("{@green}Updating repos...{@end}");
    for (final repo in repos) {
      var progress = loader
          .progress(format(' Updating {@blue}${repoName(repo.url)}{@end}'));
      final remote = repo.url;
      final local = (await dir(remote.slugify())).path;
      if (await XPM.isGit(Directory(local))) {
        await XPM.git(['-C', local, 'pull']);
      } else {
        await XPM.git(['clone', remote, local]);
      }
      progress.finish(showTiming: true);
    }
  }

  static index() async {
    final db = await DB.instance();
    await db.writeTxn(() async {
      await db.packages.clear();
    });
    await pull();

    final repos = await allRepos();

    for (final repo in repos) {
      final remote = repo.url;
      final local = (await dir(remote.slugify())).path;
      final packages =
          (await Directory(local).list().toList()).whereType<Directory>();

      for (final packageFolder in packages) {
        final packageBasename = p.basename(packageFolder.path);
        if (packageBasename.startsWith('.')) {
          continue;
        }

        final packageFile = File('${packageFolder.path}/$packageBasename.bash');
        if (!await packageFile.exists()) {
          continue;
        }

        // @TODO Validate bash file
        final package = Package()
          ..name = packageBasename
          ..repo.value = repo;
        db.writeTxnSync(() async {
          db.packages.putSync(package);
        });
      }
    }
  }
}
