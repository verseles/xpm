import 'dart:io';

import 'package:xpm/os/bin_directory.dart';
import 'package:xpm/os/run.dart';
import 'package:path/path.dart';

// @FIXME Currently, this function uses one directory to search for the file, but should
// use all directories in the PATH environment variable.

/// Deletes a [file] from the system's bin folder.
/// If [binDir] is not specified, the system's bin folder will be used.
/// If [runner] is not specified, a new [Run] instance will be used.
/// If [sudo] is true, the file will be deleted using sudo.
///
/// Returns true if the file was deleted successfully, false otherwise.
Future<bool> deleteFromBin(File file,
    {Run? runner, Directory? binDir, bool sudo = true, force = true}) async {
  binDir ??= binDirectory();
  runner ??= Run();

  try {
    final fileInBinDir =
        File(join(binDir.absolute.path, basename(file.absolute.path)));
    final success = await runner.delete(fileInBinDir.absolute.path,
        sudo: sudo, force: force);
    return success;
  } catch (e) {
    return false;
  }
}
