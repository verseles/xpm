import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/os/repositories.dart';

void main() async {
  final db = await DB.instance();

  final packages = await db.packages.where().findAll();

  for (final package in packages) {
    print(package.repo);
  }
}
