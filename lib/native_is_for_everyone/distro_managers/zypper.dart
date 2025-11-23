import 'package:process_run/process_run.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

/// Package manager adapter for openSUSE/SLES systems using Zypper
class ZypperPackageManager extends NativePackageManager {
  @override
  Future<List<NativePackage>> search(String name, {int? limit}) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('zypper --non-interactive search "$name" 2>/dev/null');

    if (result.first.exitCode != 0) {
      return [];
    }

    final packages = _parseSearchOutput(result.first.stdout.toString());

    if (limit != null) {
      return packages.take(limit).toList();
    }

    return packages;
  }

  List<NativePackage> _parseSearchOutput(String output) {
    final packages = <NativePackage>[];
    final lines = output.split('\n');

    // Skip header lines (zypper has a table format with headers)
    bool headerPassed = false;

    for (final line in lines) {
      if (line.isEmpty) continue;

      // Skip separator lines
      if (line.startsWith('--') || line.startsWith('S ') || line.contains('| Name')) {
        headerPassed = true;
        continue;
      }

      if (!headerPassed) continue;

      // Zypper output format: "S | Name | Summary | Type"
      // or "i | package-name | Description | package"
      final parts = line.split('|');
      if (parts.length < 3) continue;

      final name = parts[1].trim();
      final description = parts[2].trim();

      if (name.isEmpty) continue;

      packages.add(NativePackage(
        name: name,
        description: description,
        repo: 'opensuse',
      ));
    }

    return packages;
  }

  @override
  Future<void> install(String name) async {
    final sudo = await Executable('sudo').find();
    if (sudo == null) {
      throw Exception('sudo not found');
    }
    final shell = Shell();
    await shell.run('$sudo zypper --non-interactive install "$name"');
  }

  @override
  Future<bool> isInstalled(String name) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('rpm -q "$name" 2>/dev/null');
    return result.first.exitCode == 0;
  }

  @override
  Future<NativePackage?> get(String name) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('zypper --non-interactive info "$name" 2>/dev/null');

    if (result.first.exitCode != 0) {
      return null;
    }

    return _parsePackageInfo(name, result.first.stdout.toString());
  }

  NativePackage _parsePackageInfo(String packageName, String output) {
    String? version;
    String? description;
    String? arch;
    String? repo;

    for (final line in output.split('\n')) {
      final colonIndex = line.indexOf(':');
      if (colonIndex == -1) continue;

      final field = line.substring(0, colonIndex).trim().toLowerCase();
      final value = line.substring(colonIndex + 1).trim();

      switch (field) {
        case 'version':
        case 'versão':
          version = value;
          break;
        case 'summary':
        case 'description':
        case 'descrição':
          description = value;
          break;
        case 'arch':
        case 'architecture':
        case 'arquitetura':
          arch = value;
          break;
        case 'repository':
        case 'repositório':
          repo = value;
          break;
      }
    }

    return NativePackage(
      name: packageName,
      version: version,
      description: description,
      arch: arch,
      repo: repo,
    );
  }
}
