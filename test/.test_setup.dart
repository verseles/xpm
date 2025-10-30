import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';

Future<void> main() async {
  await Isar.initializeIsarCore(download: true);
  await DB.instance();
}
