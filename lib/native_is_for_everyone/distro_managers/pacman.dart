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
    final shell = Shell(verbose: false);
    final helper = await _getBestHelper();

    // Use the best available helper (Paru/Yay handle both repos + AUR automatically)
    final result = await shell.run('$helper -Ss --noconfirm "$name"');

    if (result.first.exitCode != 0) {
      return [];
    }

    final packages = _parseSearchOutput(result.first.stdout.toString());

    // Separate official repo packages from AUR packages
    final officialPackages = <NativePackage>[];
    final aurPackages = <NativePackage>[];

    for (final pkg in packages) {
      if (pkg.repo == 'aur') {
        aurPackages.add(pkg);
      } else {
        officialPackages.add(pkg);
      }
    }

    // Sort official packages alphabetically
    officialPackages.sort((a, b) => a.name.compareTo(b.name));

    // Sort AUR packages by popularity (ascending - less popular first, most popular last)
    aurPackages.sort((a, b) {
      final aPop = a.popularity ?? 0;
      final bPop = b.popularity ?? 0;
      return aPop.compareTo(bPop);
    });

    // Start with officials (limit to ~7)
    final combined = <NativePackage>[];
    combined.addAll(officialPackages.take(7));

    // Add all AUR packages (don't limit them to ensure most popular appear at the end)
    combined.addAll(aurPackages);

    // Only apply limit if it's a large value to ensure AUR packages aren't cut off
    // The search command will handle final limiting if needed
    if (limit != null && limit > 50) {
      return combined.take(limit).toList();
    }

    return combined;
  }

  List<NativePackage> _parseSearchOutput(String output) {
    final packages = <NativePackage>[];
    final lines = output.split('\n').where((line) => line.isNotEmpty).toList();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Parse lines like: "extra/jq 1.8.1-1 Command-line JSON processor" or "aur/whyq 0.15.0-1 [+0 ~0.00]"
      final parts = line.split(' ');
      if (parts.length < 2) continue;

      final repositoryArch = parts[0].split('/');
      String name;
      String version;
      String description = '';
      String repo = repositoryArch[0];
      int? popularity;

      if (repositoryArch[0] == 'aur') {
        // AUR format: "aur/package version [+votes ~popularity]" (paru) or "aur/package version (+votes popularity)" (yay)
        name = repositoryArch[1]; // Second part is the package name
        version = parts[1];

        // Extract votes and popularity from stats like [+67 ~2.84] (paru) or (+67 2.84) (yay)
        // Try both patterns
        final paruPattern = RegExp(r'\[\+(\d+)\s+~([0-9\.]+)\]');
        final yayPattern = RegExp(r'\(\+(\d+)\s+([0-9\.]+)\)');

        var match = paruPattern.firstMatch(line);
        if (match != null) {
          final popularityValue = double.parse(match.group(2)!);
          // Store popularity as integer (multiply by 100 to preserve 2 decimal places)
          popularity = (popularityValue * 100).round();
        } else {
          match = yayPattern.firstMatch(line);
          if (match != null) {
            final popularityValue = double.parse(match.group(2)!);
            // Store popularity as integer (multiply by 100 to preserve 2 decimal places)
            popularity = (popularityValue * 100).round();
          }
        }

        // Description is on the next line if present
        if (i + 1 < lines.length) {
          final nextLine = lines[i + 1];
          // Check if next line looks like a description (starts with spaces/tabs and has content)
          if (nextLine.trim().isNotEmpty && (nextLine.startsWith(' ') || nextLine.startsWith('\t'))) {
            description = nextLine.trim();
            i++; // Skip the next line as it's been used as description
          }
        }
      } else if (repositoryArch.length >= 2) {
        // Official repo format: "repo/package version [size1 size2] [installed: version]"
        name = repositoryArch[1];
        version = parts[1];
        repo = repositoryArch[0]; // extra, core, community, etc.
        // Get description from the same line if present
        if (parts.length > 2) {
          description = parts.sublist(2).join(' ').trim();
        }
      } else {
        continue;
      }

      packages.add(
        NativePackage(name: name, version: version, description: description, repo: repo, popularity: popularity),
      );
    }

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
