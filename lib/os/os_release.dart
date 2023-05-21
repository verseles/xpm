import 'dart:io';

// @TODO Publish as a package
String? osRelease(String name) {
  Map<String, String> osRelease = <String, String>{};
  if (Platform.isLinux) {
    final List<String> lines = File('/etc/os-release').readAsLinesSync();
    osRelease = <String, String>{};
    for (String e in lines) {
      List<String> data = e.split('=');
      osRelease[data[0]] = data[1].replaceAll('"', '');
    }
  } else if (Platform.isMacOS) {
    osRelease['ID'] = 'macos';
    osRelease['ID_LIKE'] = 'darwin';
    osRelease['VERSION_ID'] = Platform.operatingSystemVersion;
  } else if (Platform.isWindows) {
    osRelease['ID'] = 'windows';
    osRelease['ID_LIKE'] = 'windows';
    osRelease['VERSION_ID'] = Platform.operatingSystemVersion;
  }

  return osRelease[name];
}
