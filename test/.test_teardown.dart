import 'package:xpm/database/db.dart';

Future<void> main() async {
  final db = await DB.instance();
  await db.close();
}
