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
  static Future<void> set(String key, dynamic value) async {
    final db = await DB.instance();
    final data = KV()
      ..key = key.toLowerCase()
      ..value = serialize(value);

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

  /// Deletes a setting with the specified key.
  ///
  /// Parameters:
  /// - [key]: A unique key for the setting to delete. It is case-insensitive and will be searched in lowercase.
  static Future<void> delete(String key) async {
    key = key.toLowerCase();

    final db = await DB.instance();

    await db.writeTxn(() async => await db.kVs.deleteByKey(key));

    _cache.remove(key);
  }

  // Factory to save cached values in a list map
  factory Setting() => _instance;
  static final _instance = Setting._privateConstructor();
  Setting._privateConstructor();
}
