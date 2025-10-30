import 'dart:io';

import 'package:xpm/os/bin_directory.dart';
import 'package:xpm/os/run.dart';
import 'package:path/path.dart';

/// Moves a [file] to the system's bin folder.
/// If [binDir] is not specified, the system's bin folder will be used.
/// If [runner] is not specified, a new [Run] instance will be used.
/// If [sudo] is true, the file will be moved using sudo.
Future<File?> moveToBin(
  File file, {
  Run? runner,
  Directory? binDir,
  bool sudo = true,
}) async {
  binDir ??= binDirectory();
  runner ??= Run();

  try {
    final dest = File(join(binDir.absolute.path, basename(file.absolute.path)));
    final success = await runner.move(
      file.absolute.path,
      dest.absolute.path,
      sudo: sudo,
    );
    if (success) {
      return dest.absolute;
    }
  } catch (e) {
    return null;
  }

  return null;
}
