import 'dart:io';

/// Returns the path to the system's binary folder.
///
/// On non-Windows systems, it searches the directories listed in the PATH
/// environment variable for `/usr/bin` and `/usr/local/bin` and returns the
/// path to the first one found. If neither is found, it returns the path to
/// the first directory in PATH that exists.
///
/// On Windows systems, it checks if the ProgramFiles folder exists and returns
/// its path. If it does not exist, it returns the path to the System32 folder.
///
/// Throws an exception if no binary folder was found.
// ignore: non_constant_identifier_names
Directory binDirectory({String? PATH}) {
  if (!Platform.isWindows) {
    {
      final String path = PATH ?? Platform.environment['PATH'] ?? '';
      List<String> paths = path.split(':');

      Directory dirLocalBin = Directory('/usr/local/bin');
      Directory dirBin = Directory('/usr/bin');
      if (paths.contains('/usr/local/bin') && dirLocalBin.existsSync()) {
        return dirLocalBin;
      } else if (paths.contains('/usr/bin') && dirBin.existsSync()) {
        return dirBin;
      } else {
        for (String p in paths) {
          Directory dir = Directory(p);
          if (dir.existsSync()) {
            return dir;
          }
        }
      }
    }
  } else {
    // Windows
    String? binDir = Platform.environment['ProgramFiles'];

    if (binDir != null) {
      Directory winBin = Directory(binDir);
      if (winBin.existsSync()) {
        return winBin;
      }
    } else {
      binDir = r'C:\Windows\System32';
      Directory winBin = Directory(binDir);
      if (winBin.existsSync()) {
        return winBin;
      }
    }
  }
  throw Exception(
    'No executable folder was found in the PATH environment variable.',
  );
}
