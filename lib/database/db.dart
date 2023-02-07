import 'package:isar/isar.dart';

import '../xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

class DB {
  static Future<Isar> instance() async {
    await Isar.initializeIsarCore(download: true);

    final dbDir = await XPM.dataDir('');

// Check if isar is open
    return Isar.getInstance('index') ??
        await Isar.open([RepoSchema, PackageSchema],
            directory: dbDir.path, relaxedDurability: true, name: 'index');
  }
}
