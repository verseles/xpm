import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/setting.dart' as model;

class Setting {
  static final Map<String, dynamic> _cache = {};

  static Future<void> set(String key, dynamic value) async {
    final db = await DB.instance();
    final data = model.Setting()
      ..key = key
      ..value = value;

    db.writeTxnSync(() {
      db.settings.put(data);
    });

    _cache[key] = value;
  }

  static Future<dynamic> get(String key,
      {dynamic defaultValue, bool cache = true}) async {
    if (cache && _cache.containsKey(key)) {
      return _cache[key];
    } else {
      final db = await DB.instance();
      final data = await db.settings.where().keyEqualTo(key).findFirst();
      if (data != null) {
        _cache[key] = data.value;
        return data.value;
      } else {
        return defaultValue;
      }
    }
  }

  static Future<void> delete(String key) async {
    final db = await DB.instance();
    await db.settings.where().keyEqualTo(key).deleteFirst();

    _cache.remove(key);
  }

  // Factory to save cached values in a list map
  factory Setting() => _instance;
  static final _instance = Setting._privateConstructor();
  Setting._privateConstructor();
}
