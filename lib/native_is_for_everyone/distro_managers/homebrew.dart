import 'package:process_run/process_run.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';

/// Package manager adapter for macOS using Homebrew
class HomebrewPackageManager extends NativePackageManager {
  @override
  Future<List<NativePackage>> search(String name, {int? limit}) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('brew search "$name" 2>/dev/null');

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

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip header lines
      if (trimmed.startsWith('==>') || trimmed.contains('Formulae') || trimmed.contains('Casks')) {
        continue;
      }

      // Each line is a package name (sometimes with cask marker)
      // Format can be: "package-name" or "package-name (installed)"
      final name = trimmed.replaceAll(RegExp(r'\s*\(installed\).*'), '').trim();

      if (name.isNotEmpty) {
        packages.add(NativePackage(
          name: name,
          repo: 'homebrew',
        ));
      }
    }

    return packages;
  }

  @override
  Future<void> install(String name) async {
    final shell = Shell();
    await shell.run('brew install "$name"');
  }

  @override
  Future<bool> isInstalled(String name) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('brew list "$name" 2>/dev/null');
    return result.first.exitCode == 0;
  }

  @override
  Future<NativePackage?> get(String name) async {
    final shell = Shell(verbose: false);
    final result = await shell.run('brew info "$name" 2>/dev/null');

    if (result.first.exitCode != 0) {
      return null;
    }

    return _parsePackageInfo(name, result.first.stdout.toString());
  }

  NativePackage _parsePackageInfo(String packageName, String output) {
    String? version;
    String? description;

    final lines = output.split('\n');

    // First line usually has format: "name: stable version"
    if (lines.isNotEmpty) {
      final firstLine = lines[0];
      final versionMatch = RegExp(r'stable\s+([^\s,]+)').firstMatch(firstLine);
      if (versionMatch != null) {
        version = versionMatch.group(1);
      }
    }

    // Description is usually on second line
    if (lines.length > 1) {
      description = lines[1].trim();
    }

    return NativePackage(
      name: packageName,
      version: version,
      description: description,
      repo: 'homebrew',
    );
  }
}
