import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:xpm/database/models/kv.dart';
import 'package:xpm/utils/logger.dart';

import 'package:xpm/xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

class DB {
  static Future<Isar> instance() async {
    final dbName = 'index';
    final dataDir = await XPM.dataDir('isar');
    final coreFile = File('${dataDir.path}/libisar.so');
    final dbFile = File('${dataDir.path}/$dbName.isar');

    final libraries = <Abi, String>{};
    for (var abi in Abi.values) {
      libraries[abi] = coreFile.path;
    }

    if (!dbFile.existsSync() || !coreFile.existsSync()) {
      Logger.info('Creating database... This may take a while.');
    }

    await Isar.initializeIsarCore(download: true, libraries: libraries);

    if (Isar.getInstance(dbName) == null) {
      await Isar.open([RepoSchema, PackageSchema, KVSchema],
          directory: dataDir.path, relaxedDurability: true, name: dbName);
    }

    if (Isar.getInstance(dbName) == null) {
      throw Exception('Failed to open database');
    }

    return Isar.getInstance(dbName)!;
  }
}
