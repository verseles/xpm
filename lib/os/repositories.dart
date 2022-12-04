import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';

import 'package:xpm/xpm.dart';

class Repositories {
  /// Returns working directory
  static final Map<String, Future<Directory>> __dirs = {};

  static Future<Directory> dir(String? repo, {package = ''}) async {
    final reposDir = await getReposDir();

    final dir = Directory("${reposDir.path}/$repo/$package");
    return dir.create(recursive: true);
  }

  static Future<Directory> getReposDir() async {
    return __dirs.putIfAbsent(
        'reposDir', () async => (await XPM.dataDir('repos')));
  }

  addRepo(String url) async {
    final db = await DB.instance();
    final repo = Repo()..url = url;
    await db.writeTxn((isar) async {
      await isar.repos.put(repo);
    });
  }

  getPopular() async {
    final remote = 'https://github.com/verseles/xpm-popular.git';
    final local = (await dir('xpm-popular')).path;

    if (await XPM.isGit(Directory(local))) {
      await XPM.git(['-C', local, 'pull']);
    } else {
      await XPM.git(['clone', remote, local]);
    }
  }

  index() async {
    final db = await DB.instance();
    await db.packages.clear();

    final reposDir = await getReposDir();
    final repos = (await reposDir.list().toList()).whereType<Directory>();

    for (final repo in repos) {
      final repoName = p.basename(repo.path);

      final packages = (await repo.list().toList()).whereType<Directory>();
      for (final package in packages) {
        final packageName = p.basename(package.path);
        final bashFile = File('${package.path}/$packageName.bash');
        if (await bashFile.exists()) {}
      }
    }
  }
}
