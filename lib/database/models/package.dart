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

  @Index(caseSensitive: false)
  List<String>? arch; // supported architectures

  @Index(caseSensitive: false)
  List<String>? methods; // supported methods

  @Index(caseSensitive: false)
  List<String>? defaults; // supported default methods

  @Index(caseSensitive: false)
  String? installed; // version installed

  String? method; // method used to install

  String? channel; // channel used to install

  final repo = IsarLink<Repo>();
}
