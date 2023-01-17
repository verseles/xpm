import 'package:isar/isar.dart';
import 'package:xpm/database/models/repo.dart';

part 'package.g.dart';

@collection
class Package {
  Id? id;

  late String script; // path to script

  @Index(caseSensitive: false)
  late String name;

  @Index(caseSensitive: false)
  String? desc;

  String? version;

  @Index(caseSensitive: false)
  String? title;

  String? url;

  @Index()
  bool? installed;

  final repo = IsarLink<Repo>();
}
