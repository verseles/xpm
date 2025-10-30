import 'package:xpm/native/models/native_package.dart';
import 'package:xpm/native/native_package_manager.dart';
import 'package:xpm/os/run.dart';

class AptPackageManager implements NativePackageManager {
  final Run _runner;

  AptPackageManager({Run? runner}) : _runner = runner ?? Run();

  @override
  Future<List<NativePackage>> search(String query, {int limit = 20}) async {
    final searchResult = await _runner.simple('apt-cache', ['search', query]);
    if (searchResult.exitCode != 0) {
      return [];
    }

    final lines = searchResult.stdout.split('\n');
    final packages = <NativePackage>[];
    for (final line in lines) {
      if (line.isEmpty) {
        continue;
      }
      final parts = line.split(' - ');
      final name = parts[0].trim();
      final description = parts.length > 1 ? parts[1].trim() : null;

      final showResult = await _runner.simple('apt-cache', ['show', name]);
      if (showResult.exitCode != 0) {
        continue;
      }

      final showOutput = showResult.stdout;
      final versionMatch = RegExp(
        r'^Version: (.*)$',
        multiLine: true,
      ).firstMatch(showOutput);
      final version = versionMatch?.group(1);

      final installed = await isInstalled(name);

      packages.add(
        NativePackage(
          name: name,
          version: version,
          description: description,
          isInstalled: installed,
          source: 'apt',
        ),
      );

      if (packages.length >= limit) {
        break;
      }
    }

    return packages;
  }

  @override
  Future<void> install(String package) async {
    await _runner.simple('apt', ['install', '-y', package], sudo: true);
  }

  @override
  Future<bool> isInstalled(String package) async {
    final result = await _runner.simple('dpkg-query', [
      '-W',
      '-f=\'\'',
      package,
    ]);
    return result.exitCode == 0;
  }

  @override
  Future<NativePackage?> getPackageDetails(String package) async {
    final result = await _runner.simple('dpkg-query', [
      '-W',
      r'-f=${Package}\t${Version}\t${description}',
      package,
    ]);
    if (result.exitCode != 0) {
      return null;
    }

    final parts = result.stdout.trim().split('\t');
    if (parts.length < 3) {
      return null;
    }

    return NativePackage(
      name: parts[0],
      version: parts[1],
      description: parts[2],
      isInstalled: true,
      source: 'apt',
    );
  }
}
