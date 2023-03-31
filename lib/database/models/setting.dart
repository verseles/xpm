import 'package:isar/isar.dart';

part 'setting.g.dart';

@collection
class Setting {
  Id? id;

  /// The key of the setting.
  @Index(unique: true, caseSensitive: true)
  late String key;

  /// The value of the setting.
  late String value;

  /// UTC timestamp of when the setting expires.
  /// @TODO: Implement this.
  late DateTime expiresAt;
}
