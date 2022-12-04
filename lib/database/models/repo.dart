import 'package:isar/isar.dart';
import 'package:xpm/database/models/package.dart';

part 'repo.g.dart';

@collection
class Repo {
  Id? id;

  late String url;

  @Backlink(to: 'repo')
  final package = IsarLinks<Package>();
}
