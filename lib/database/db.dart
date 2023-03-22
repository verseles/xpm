import 'dart:io';

import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:isar/isar.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/out.dart';

import 'package:xpm/xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

class DB {
  static Future<Isar> instance() async {
    await Isar.initializeIsarCore(download: true);

    final dbDir = await XPM.dataDir('');

// Warn that the database is being created
    final dbFile = File('${dbDir.path}/index.isar');
    if (!dbFile.existsSync()) {
      Logger.info('Creating database... This may take a while.');
    }
    final isarInstance = Isar.getInstance('index');
    if (isarInstance == null) {
      Logger.info('Opening database...');
      return await Isar.open([RepoSchema, PackageSchema],
          directory: dbDir.path, relaxedDurability: true, name: 'index');
    } else  {
      Logger.info('Database already open. Skipping...');
      return isarInstance;
    }
  }
}
