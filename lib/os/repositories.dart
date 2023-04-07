import 'dart:io';
import 'package:console/console.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slug/slug.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/slugify.dart';

import 'package:xpm/xpm.dart';

class Repositories {
  /// Returns working directory
  static final Map<String, Future<Directory>> __dirs = {};

  static Future<Directory> dir(String? repo,
      {package = '', create = true}) async {
    final reposDir = await getReposDir();
    final repoAsSlug = repo?.slugify() ?? '';

    final dir = Directory("${reposDir.path}/$repoAsSlug/$package");
    if (create) {
      return dir.create(recursive: true);
    }

    return dir;
  }

  static Future<Directory> getReposDir() async =>
      __dirs.putIfAbsent('reposDir', () async => (await XPM.dataDir('repos')));

  static Future<void> addRepo(String remote) async {
    final localDirectory = await dir(remote);
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

  static Future<void> addPopular() async {
    await addRepo('https://github.com/verseles/xpm-popular.git');
  }

  static String repoName(String url) {
    final parts = url.split('/');
    if (parts.length < 2) {
      return 'unknown';
    }
    return parts.sublist(parts.length - 2).join('/').replaceAll('.git', '');
  }

  // Pull or clone all repos
  static Future<void> pull() async {
    final Slug loader = Slug(slugStyle: SlugStyle.toggle);
    List<Repo> repos = await allRepos();

    if (repos.isEmpty) {
      await addPopular();
      repos = await allRepos();
    }

    out("{@green}Updating repos...{@end}");
    for (final repo in repos) {
      var progress = loader
          .progress(format(' Updating {@blue}${repoName(repo.url)}{@end}'));
      final remote = repo.url;
      final localRepoDirPath = (await dir(remote.slugify())).path;
      if (await XPM.isGit(Directory(localRepoDirPath))) {
        await XPM.git(['-C', localRepoDirPath, 'reset', '--hard']);
        await XPM.git(['-C', localRepoDirPath, 'pull', '--force', '--rebase']);
      } else {
        await XPM.git(['clone', remote, localRepoDirPath]);
      }
      progress.finish(showTiming: true);
    }
  }

  static index() async {
    final db = await DB.instance();
    await db.writeTxn(() async {
      await db.packages.where().installedIsNull().deleteAll();
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

        String pathScript = '${packageFolder.path}/$packageBasename.bash';
        final BashScript bashScript = BashScript(pathScript);

        if (!await bashScript.exists()) {
          continue;
        }

        final desc = bashScript.get('xDESC');
        final version = bashScript.get('xVERSION');
        final title = bashScript.get('xTITLE');
        final url = bashScript.get('xURL');
        final arch = bashScript.getArray('xARCH');

        final List<dynamic> results = await Future.wait([desc, version, title, url, arch]);
        print(results);

        // @TODO Validate bash file
        final package = Package()
          ..name = packageBasename
          ..repo.value = repo
          ..script = pathScript
          ..desc = results[0]
          ..version = results[1]
          ..title = results[2]
          ..url = results[3]
          ..arch = results[4];

        db.writeTxnSync(() {
          db.packages.putSync(package);
        });
      }
    }
  }
}
