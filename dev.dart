import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';

void main() async {
  final db = await DB.instance();

  final packages = await db.packages.where().findAll();

  for (final package in packages) {
    var repo = package.repo;
    print(repo.value!.url);
  }
}
