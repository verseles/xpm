import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:xpm/database/models/kv.dart';
import 'package:xpm/utils/logger.dart';

import 'package:xpm/xpm.dart';
import 'models/package.dart';
import 'models/repo.dart';

/// A class that creates and manages an Isar database.
class DB {
  /// Returns an instance of the Isar database.
  static Future<Isar> instance() async {
    // Define the name of the database and the data directory.
    final dbName = 'index';
    final dataDir = await XPM.dataDir('isar');

    // Define the paths to the Isar core and database files.
    final coreFile = File('${dataDir.path}/libisar.so');
    final dbFile = File('${dataDir.path}/$dbName.isar');

    // Define the libraries to load for each ABI.
    final libraries = <Abi, String>{};
    for (var abi in Abi.values) {
      libraries[abi] = coreFile.path;
    }

    // If the database or core files don't exist, display a message indicating that the database is being created.
    if (!dbFile.existsSync() || !coreFile.existsSync()) {
      Logger.info('Creating database... This may take a while.');
    }

    // Initialize the Isar core and load the necessary libraries.
    await Isar.initializeIsarCore(download: true, libraries: libraries);

    // Open the database and create the necessary tables.
    if (Isar.getInstance(dbName) == null) {
      await Isar.open(
        [RepoSchema, PackageSchema, KVSchema],
        directory: dataDir.path,
        relaxedDurability: true,
        name: dbName,
      );
    }

    // If the database instance cannot be opened, throw an exception.
    if (Isar.getInstance(dbName) == null) {
      throw Exception('Failed to open database');
    }

    // Return the Isar database instance.
    return Isar.getInstance(dbName)!;
  }
}
