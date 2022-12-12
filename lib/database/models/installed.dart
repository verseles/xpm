import 'package:isar/isar.dart';
import 'package:xpm/database/models/package.dart';

part 'installed.g.dart';

@collection
class Installed {
  Id? id;

  @Index(unique: true, caseSensitive: false)
  late String name;

  final package = IsarLink<Package>();

  late String method;
}
