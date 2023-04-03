import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/kv.dart';
import 'package:xpm/utils/json.dart';

/// A class for working with application settings.
class Setting {
  /// A map used for caching setting values to avoid database queries.
  static final Map<String, dynamic> _cache = {};

  /// Sets a value for a setting with the specified key.
  ///
  /// Parameters:
  /// - [key]: A unique key for the setting. It is case-insensitive and will be stored in lowercase.
  /// - [value]: The value to set for the setting.
  static Future<void> set(String key, dynamic value,
      {DateTime? expires}) async {
    final db = await DB.instance();
    final data = KV()
      ..key = key.toLowerCase()
      ..value = serialize(value)
      ..expiresAt = expires;

    await db.writeTxn(() async => await db.kVs.putByKey(data));

    _cache[key] = value;
  }

  /// Gets the value of a setting with the specified key.
  ///
  /// Parameters:
  /// - [key]: A unique key for the setting. It is case-insensitive and will be searched in lowercase.
  /// - [defaultValue]: The default value to return if the setting is not found. Defaults to `null`.
  /// - [cache]: Whether to cache the value in memory. Defaults to `true`.
  ///
  /// Returns: The value of the setting or the default value if it is not found.
  static Future<dynamic> get(String key,
      {dynamic defaultValue, bool cache = true}) async {
    key = key.toLowerCase();

    if (cache && _cache.containsKey(key)) {
      return _cache[key];
    } else {
      final db = await DB.instance();
      final data = await db.kVs.where().keyEqualTo(key).findFirst();
      if (data != null) {
        final value = unserialize(data.value);
        _cache[key] = value;
        return value;
      } else {
        return defaultValue;
      }
    }
  }

  /// Deletes a setting with the specified key or keys.
  ///
  /// Parameters:
  /// - [keys]: A unique key or list of keys for the setting(s) to delete. Keys are case-insensitive and will be searched in lowercase.
  /// - [lazy]: Whether to delete the setting(s) in a lazy transaction. Defaults to `false`.
  static Future<void> delete(dynamic keys, {lazy = false}) async {
    final db = await DB.instance();

    List<String> listOfKeys = keys is String ? [keys] : keys;

    final lcKeys = listOfKeys.map((String key) => key.toLowerCase()).toList();

    if (lazy) {
      db.writeTxn(() async => db.kVs.deleteAllByKey(lcKeys));
    } else {
      await db.writeTxn(() async => await db.kVs.deleteAllByKey(lcKeys));
    }

    _cache.removeWhere((key, value) => lcKeys.contains(key));
  }

  // Factory to save cached values in a list map
  factory Setting() => _instance;
  static final _instance = Setting._privateConstructor();
  Setting._privateConstructor();

  /// Delete all expired settings.
  ///
  /// This is called automatically by the database when the app starts.
  ///
  /// Parameters:
  /// - [lazy]: Whether to delete the expired settings in a lazy transaction. Defaults to `false`.
  static Future<void> deleteExpired({lazy = false}) async {
    final db = await DB.instance();
    final now = DateTime.now();

    if (lazy) {
      db.writeTxn(() async {
        db.kVs.where().expiresAtLessThan(now).deleteAll();
      });
    } else {
      await db.writeTxn(() async {
        await db.kVs.where().expiresAtLessThan(now).deleteAll();
      });
    }
  }
}
