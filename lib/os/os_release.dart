import 'dart:io';
// @TODO Publish as a package
String? osRelease(String name) {
  Map<String, String> osRelease = <String, String>{};

  final List<String> lines = File('/etc/os-release').readAsLinesSync();
  osRelease = <String, String>{};
  for (String e in lines) {
    List<String> data = e.split('=');
    osRelease[data[0]] = data[1].replaceAll('"', '');
  }

  return osRelease[name];
}
