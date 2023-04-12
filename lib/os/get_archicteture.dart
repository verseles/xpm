import 'dart:io';

/// Returns the architecture of the current device as a future [String].
String getArchitecture() {
  if (Platform.isWindows) {
    final arch = Platform.environment['PROCESSOR_ARCHITECTURE'];
    final wow64Arch = Platform.environment['PROCESSOR_ARCHITEW6432'];
    if ((arch == 'x86' && wow64Arch == null) || arch == 'AMD64') {
      return 'x86_64';
    } else {
      return 'x86';
    }
  } else {
    try {
      final result = Process.runSync('uname', ['-m']);
      if (result.exitCode == 0) {
        return result.stdout.trim();
      }
    } catch (e) {
      return 'unknown';
    }
  }
  return 'unknown';
}
