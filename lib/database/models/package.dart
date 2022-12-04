import 'package:isar/isar.dart';
import 'package:xpm/database/models/repo.dart';

part 'package.g.dart';

@collection
class Package {
  Id? id;

  late String name;

  final repo = IsarLink<Repo>();
}
