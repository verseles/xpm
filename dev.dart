import 'dart:developer';

import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';

void main() async {
  final db = await DB.instance();

  final package = await db.packages.filter().nameEqualTo('micro').findFirst();
  print(package!.repo.value!.url);
}
