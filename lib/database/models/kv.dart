import 'package:isar/isar.dart';

part 'kv.g.dart';

@collection
@Name('kv')
class KV {
  Id? id;

  /// The key
  @Index(unique: true, caseSensitive: true)
  late String key;

  /// The value
  late String value;

  /// UTC timestamp of when the setting expires.
  /// @TODO: Implement this.
  @Index()
  DateTime? expiresAt;
}
