import 'dart:io';

import 'package:xpm/xpm.dart';

class Repositories {
  /// Returns working directory
  static Future<Directory> dir(String? repo, {package = ''}) async {
    final reposDir = await XPM.dataDir('repos');
    final dir = Directory("${reposDir.path}/$repo/$package");
    return dir.create(recursive: true);
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
}
