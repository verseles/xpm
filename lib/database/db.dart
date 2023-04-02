import 'dart:io';

import 'package:isar/isar.dart';
import 'package:xpm/database/models/kv.dart';
import 'package:xpm/utils/logger.dart';

import 'package:xpm/xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

class DB {
  static Future<Isar> instance() async {
    await Isar.initializeIsarCore(download: true);

    final dbDir = await XPM.dataDir('');

    final dbFile = File('${dbDir.path}/index.isar');
    if (!dbFile.existsSync()) {
      Logger.info('Creating database... This may take a while.');
    }
    final isarInstance = Isar.getInstance('index');
    if (isarInstance == null) {
      return await Isar.open([RepoSchema, PackageSchema, KVSchema],
          directory: dbDir.path, relaxedDurability: true, name: 'index');
    } else {
      return isarInstance;
    }
  }
}
