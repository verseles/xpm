import 'package:process_run/process_run.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager.dart';
import 'package:xpm/os/executable.dart';

class PacmanPackageManager extends NativePackageManager {
  String? _bestHelper;
  String? _pacmanExec;

  /// Get the best available helper in priority order: Paru → Yay → Pacman
  Future<String> _getBestHelper() async {
    if (_bestHelper != null) return _bestHelper!;

    // Try AUR helpers first: Paru → Yay → Pacman
    final paru = await Executable('paru').find();
    if (paru != null) {
      _bestHelper = paru;
      return _bestHelper!;
    }

    final yay = await Executable('yay').find();
    if (yay != null) {
      _bestHelper = yay;
      return _bestHelper!;
    }

    final pacman = await Executable('pacman').find();
    if (pacman == null) {
      throw Exception('No package manager found (paru, yay, or pacman)');
    }

    _bestHelper = pacman;
    return _bestHelper!;
  }

  /// Get the pacman executable path (fallback only)
  Future<String> getPacmanExecutable() async {
    if (_pacmanExec != null) return _pacmanExec!;

    final pacman = await Executable('pacman').find();
    if (pacman == null) {
      throw Exception('pacman not found');
    }

    _pacmanExec = pacman;
    return _pacmanExec!;
  }

  bool get _hasSudo => _bestHelper != null && !_bestHelper!.contains('yay') && !_bestHelper!.contains('paru');

  @override
  Future<List<NativePackage>> search(String name, {int? limit}) async {
    final shell = Shell();
    final helper = await _getBestHelper();

    // Use the best available helper (Paru/Yay handle both repos + AUR automatically)
    final result = await shell.run('$helper -Ss --noconfirm "$name"');

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
    final lines = output.split('\n').where((line) => line.isNotEmpty).toList();

    for (final line in lines) {
      // Parse lines like: "extra/jq 1.8.1-1 Command-line JSON processor" or "aur/whyq 0.15.0-1 [+0 ~0.00] Description"
      final parts = line.split(' ');
      if (parts.length < 3) continue;

      final repositoryArch = parts[0].split('/');
      String name;
      String version;
      String description;

      if (repositoryArch.length >= 2) {
        // Official repo format: "repo/package version description"
        name = repositoryArch[1];
        version = parts[1];
        description = parts.sublist(2).join(' ').trim();
      } else if (repositoryArch[0].startsWith('aur/')) {
        // AUR format: "aur/package version [stats] description"
        name = repositoryArch[0].substring(4); // Remove "aur/" prefix
        version = parts[1];
        // Skip stats like [+0 ~0.00] and join the rest
        var descParts = parts.sublist(2);
        // Remove stats (like [+0 ~0.00] or [Desatualizado desde: date])
        descParts = descParts.where((p) => !p.startsWith('[') && !p.endsWith(']')).toList();
        description = descParts.join(' ').trim();
      } else {
        continue;
      }

      packages.add(NativePackage(name: name, version: version, description: description));
    }

    packages.sort((a, b) => b.name.compareTo(a.name));
    return packages;
  }

  /// Parse AUR search output (legacy method, kept for compatibility)
  List<NativePackage> parseAurOutput(String output) {
    final packages = <NativePackage>[];
    final lines = output.split('\n').where((line) => line.isNotEmpty).toList();

    for (final line in lines) {
      final parts = line.split(' ');
      if (parts.length < 3) continue;

      final nameWithAur = parts[0];
      if (!nameWithAur.startsWith('aur/')) continue;

      final name = nameWithAur.substring(4); // Remove "aur/" prefix
      final version = parts[1];

      // Join the rest as description
      final descriptionParts = parts.sublist(2);
      final description = descriptionParts.join(' ').trim();

      packages.add(NativePackage(name: name, version: version, description: description));
    }

    return packages;
  }

  /// Parse package information output
  NativePackage parsePackageInfo(String output) {
    String? name;
    String? version;
    String? description;
    String? arch;

    for (final line in output.split('\n')) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('Nome                 :')) {
        name = trimmedLine.substring('Nome                 :'.length).trim();
      } else if (trimmedLine.startsWith('Versão               :')) {
        version = trimmedLine.substring('Versão               :'.length).trim();
      } else if (trimmedLine.startsWith('Descrição            :')) {
        description = trimmedLine.substring('Descrição            :'.length).trim();
      } else if (trimmedLine.startsWith('Arquitetura          :')) {
        arch = trimmedLine.substring('Arquitetura          :'.length).trim();
      }
    }

    return NativePackage(name: name ?? 'unknown', version: version, description: description, arch: arch);
  }

  @override
  Future<void> install(String name, {bool a = true}) async {
    final shell = Shell();

    // Try helpers in priority order: Paru → Yay → Pacman
    final helpers = await _getHelpersInPriority();
    Exception? lastException;

    for (final helper in helpers) {
      try {
        final sudo = await Executable('sudo').find();

        if (_hasSudo && sudo != null) {
          await shell.run('$sudo $helper -S --noconfirm --needed "$name"');
        } else {
          await shell.run('$helper -S --noconfirm --needed "$name"');
        }

        // If we get here, installation succeeded
        return;
      } catch (e) {
        lastException = e as Exception;
        // Try next helper
      }
    }

    // If all helpers failed, throw the last exception
    throw lastException ?? Exception('Failed to install package');
  }

  /// Get all available helpers in priority order
  Future<List<String>> _getHelpersInPriority() async {
    final helpers = <String>[];

    final paru = await Executable('paru').find();
    if (paru != null) {
      helpers.add(paru);
    }

    final yay = await Executable('yay').find();
    if (yay != null) {
      helpers.add(yay);
    }

    final pacman = await Executable('pacman').find();
    if (pacman != null) {
      helpers.add(pacman);
    }

    if (helpers.isEmpty) {
      throw Exception('No package manager found');
    }

    return helpers;
  }

  @override
  Future<bool> isInstalled(String name) async {
    final shell = Shell();
    final helper = await _getBestHelper();

    final result = await shell.run('$helper -Q "$name"');
    return result.first.exitCode == 0;
  }

  @override
  Future<NativePackage?> get(String name) async {
    final shell = Shell();
    final helper = await _getBestHelper();

    final result = await shell.run('$helper -Si "$name"');

    if (result.first.exitCode != 0) {
      return null;
    }

    return parsePackageInfo(result.first.stdout.toString());
  }

  /// Get detailed installed package information
  Future<Map<String, String>?> getInstalledDetails(String name) async {
    final shell = Shell();
    final helper = await _getBestHelper();

    final result = await shell.run('$helper -Qii "$name"');

    if (result.first.exitCode != 0) {
      return null;
    }

    final details = <String, String>{};

    for (final line in result.first.stdout.toString().split('\n')) {
      final trimmedLine = line.trim();
      if (trimmedLine.contains(':')) {
        final parts = trimmedLine.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          details[key] = value;
        }
      }
    }

    return details;
  }

  /// Update package database
  Future<void> updateDatabase() async {
    final shell = Shell();
    final helper = await _getBestHelper();
    final sudo = await Executable('sudo').find();

    if (_hasSudo && sudo != null) {
      await shell.run('$sudo $helper -Sy');
    } else {
      await shell.run('$helper -Sy');
    }
  }

  /// Get AUR executable (for tests)
  Future<String?> getAurExecutable() async {
    final paru = await Executable('paru').find();
    if (paru != null) return '$paru -a';

    final yay = await Executable('yay').find();
    if (yay != null) return '$yay -a';

    return null;
  }

  /// Parse search output (for tests)
  List<NativePackage> parseSearchOutput(String output, {int? limit}) {
    final packages = _parseSearchOutput(output);

    if (limit != null) {
      return packages.take(limit).toList();
    }

    return packages;
  }
}
