import 'dart:io';
import 'package:console/console.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:slug/slug.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/database/models/repo.dart';
import 'package:xpm/os/bash_script.dart';
import 'package:xpm/setting.dart';
import 'package:xpm/utils/list_string_extensions.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/slugify.dart';

import 'package:xpm/xpm.dart';

/// A class that provides utility methods for working with repositories.
class Repositories {
  /// Returns the working directory for the given repository and package.
  ///
  /// The [repo] parameter is the URL of the repository.
  ///
  /// The [package] parameter is the name of the package within the repository.
  ///
  /// The [create] parameter indicates whether to create the directory if it does not exist.
  static final Map<String, Future<Directory>> __dirs = {};

  static Future<Directory> dir(String repoSlug,
      {package = '', create = true}) async {
    final reposDir = await getReposDir();

    final dir = Directory("${reposDir.path}/$repoSlug/$package");
    if (create) {
      return dir.create(recursive: true);
    }

    return dir;
  }

  /// Returns the directory where repositories are stored.
  static Future<Directory> getReposDir() async =>
      __dirs.putIfAbsent('reposDir', () async => (await XPM.dataDir('repos')));

  /// Adds a new repository to the local database and clones it if it does not exist.
  ///
  /// The [remote] parameter is the URL of the repository.
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

  /// Returns a list of all repositories in the local database.
  static Future<List<Repo>> allRepos() async {
    final db = await DB.instance();
    final repos = await db.repos.where().findAll();
    return repos;
  }

  /// Adds the popular repository to the local database and clones it if it does not exist.
  static Future<void> addPopular() async {
    await addRepo('https://github.com/verseles/xpm-popular.git');
  }

  /// Returns the name of the repository from the given URL.
  ///
  /// The [url] parameter is the URL of the repository.
  static String repoName(String url) {
    final parts = url.split('/');
    if (parts.length < 2) {
      return 'unknown';
    }
    return parts.sublist(parts.length - 2).join('/').replaceAll('.git', '');
  }

  /// Updates all repositories in the local database by pulling the latest changes from their remote repositories.
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

    // Delete all packages that are not currently installed from the local database.
    await db.writeTxn(() async {
      await db.packages.where().installedIsNull().deleteAll();
    });

    // Pull the latest changes from all remote repositories.
    await pull();

    // Index all packages in each repository.
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

        // Read the package's metadata from its Bash script.
        String pathScript = '${packageFolder.path}/$packageBasename.bash';
        final BashScript bashScript = BashScript(pathScript);
        if (!await bashScript.exists()) {
          continue;
        }
        final desc = bashScript.get('xDESC');
        final version = bashScript.get('xVERSION');
        final title = bashScript.get('xTITLE');
        final url = bashScript.get('xURL');
        final archs = bashScript.getArray('xARCH');
        final defaults = bashScript.getArray('xDEFAULT');

        final installMethodFutures = XPM.installMethods.keys
            .toList()
            .where((method) => method != 'auto')
            .map((method) => bashScript
                .hasFunction('install_$method')
                .then((value) => value ? method : null));

        final List<String?> availableMethods =
            await Future.wait(installMethodFutures);

        final List<dynamic> results =
            await Future.wait([desc, version, title, url, archs, defaults]);

        final Map<String, dynamic> data = {
          'desc': results[0],
          'version': results[1],
          'title': results[2],
          'url': results[3],
          'arch':
              (results[4] as List<String>).standardize(XPM.archCorrespondence),
          'defaults': results[5],
          'methods': availableMethods.whereType<String>().toList(),
        };

        // Add the package's metadata to the local database.
        final package = Package()
          ..repo.value = repo
          ..name = packageBasename
          ..script = pathScript
          ..desc = data['desc']
          ..version = data['version']
          ..title = data['title']
          ..url = data['url']
          ..arch = data['arch']
          ..defaults = data['defaults']
          ..methods = data['methods'];

        /// WARN: async is not working and is a hell to debug
        db.writeTxnSync(() {
          db.packages.putByIndexSync('name', package);
        });
      }
    }

    // Set a flag in the local settings to indicate that the package list needs to be refreshed after three days.
    final threeDays = DateTime.now().add(Duration(days: 3));
    Setting.set('needs_refresh', true, expires: threeDays, lazy: true);
  }
}
