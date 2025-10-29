import 'dart:io';

/// Returns the architecture of the current system.
String getArchitecture() {
  String result = 'unknown';
  try {
    final arch = Process.runSync('uname', ['-m']);
    if (arch.exitCode == 0) {
      result = arch.stdout.trim();
    }
  } catch (e) {
    return result;
  }

  return normalizeCPUName(result);
}

/// Returns a normalized CPU name.
///
/// This function is used to normalize the output of `uname -m` to a more
/// common name.
String normalizeCPUName(String cpuName) {
  Map<String, String> cpuNameMap = {
    'amd64': 'x86_64',
    'x64': 'x86_64',
    'i686': 'x86',
    'i386': 'x86',
    'armv7': 'arm',
    'aarch64': 'arm64',
    'm1': 'arm64',
    'm2': 'arm64',
    'm3': 'arm64',
    'apple': 'arm64',
    'armv6l': 'arm',
    'armv8': 'arm64',
    'arm64v8': 'arm64',
    'ppc64le': 'ppc64',
    'ppc64el': 'ppc64',
    's390x': 's390',
  };

  return cpuNameMap[cpuName.toLowerCase()] ?? cpuName;
}
