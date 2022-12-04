import 'package:isar/isar.dart';

import '../xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

class DB {
  static instance() async {
    final dbDir = await XPM.dataDir(null);
    final isar = Isar.open([RepoSchema, PackageSchema],
        directory: dbDir.path, relaxedDurability: true, name: 'index');

    return isar;
  }
}
