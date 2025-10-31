import 'package:process_run/process_run.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

class AptPackageManager extends NativePackageManager {
  @override
  Future<List<NativePackage>> search(String name, {int? limit}) async {
    final shell = Shell();
    final result = await shell.run(
        'apt-cache search --names-only "^$name"');
    if (result.first.exitCode != 0) {
      return [];
    }

    var lines = result.first.stdout.toString().split('\n');
    lines.sort((a, b) => b.compareTo(a));
    if (limit != null) {
      lines = lines.take(limit).toList();
    }

    final packages = <NativePackage>[];
    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      final parts = line.split(' - ');
      packages.add(
          NativePackage(name: parts[0], description: parts.length > 1 ? parts[1] : null));
    }

    return packages;
  }

  @override
  Future<void> install(String name, {bool a = true}) async {
    final sudo = await Executable('sudo').find();
    if (sudo == null) {
      throw Exception('sudo not found');
    }
    final shell = Shell();
    await shell.run(
        '$sudo apt-get install -y "$name"');
  }

  @override
  Future<bool> isInstalled(String name) async {
    final shell = Shell();
    final result =
        await shell.run('dpkg-query --show --showformat=\'${"Status"}\' "$name"');
    if (result.first.exitCode != 0) {
      return false;
    }

    return result.first.stdout.toString().contains('install ok installed');
  }

  @override
  Future<NativePackage?> get(String name) async {
    final shell = Shell();
    final result =
        await shell.run('apt-cache show "$name"');
    if (result.first.exitCode != 0) {
      return null;
    }

    String? version;
    String? description;
    String? arch;

    for (final line in result.first.stdout.toString().split('\n')) {
      if (line.startsWith('Version: ')) {
        version = line.substring('Version: '.length);
      } else if (line.startsWith('Description: ')) {
        description = line.substring('Description: '.length);
      } else if (line.startsWith('Architecture: ')) {
        arch = line.substring('Architecture: '.length);
      }
    }
    return NativePackage(name: name, version: version, description: description, arch: arch);
  }
}
