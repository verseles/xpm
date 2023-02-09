import 'dart:io';

/// Returns the architecture of the current device as a future [String].
Future<String> getArchitecture() async {
  if (Platform.isWindows) {
    return 'x86';
  } else if (Platform.isMacOS) {
    return 'x86_64';
  } else if (Platform.isLinux) {
    final result = await Process.run('uname', ['-m']);
    if (result.exitCode == 0) {
      return result.stdout.trim();
    }
  }
  return 'unknown';
}
