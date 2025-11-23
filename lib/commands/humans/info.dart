import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager_detector.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that shows detailed information about a package.
class InfoCommand extends Command {
  @override
  final name = "info";

  @override
  final aliases = ['show', 'details', 'i'];

  @override
  final description = "Show detailed information about a package";

  @override
  final category = "For humans";

  InfoCommand() {
    argParser.addFlag(
      'native',
      negatable: true,
      defaultsTo: true,
      abbr: 'n',
      help: 'Also check native package manager for package info.',
    );
  }

  @override
  Future<void> run() async {
    final List<String> packagesRequested = argResults!.rest;
    final bool checkNative = argResults!['native'];

    showUsage(packagesRequested.isEmpty, () => printUsage());

    final db = await DB.instance();

    for (final packageName in packagesRequested) {
      await _showPackageInfo(db, packageName, checkNative);
      if (packagesRequested.length > 1) {
        print(''); // Add spacing between packages
      }
    }
  }

  Future<void> _showPackageInfo(Isar db, String packageName, bool checkNative) async {
    // First, check XPM database
    final xpmPackage = await db.packages.filter().nameEqualTo(packageName).findFirst();

    // Then, check native package manager
    var nativePackage = checkNative ? await _getNativePackageInfo(packageName) : null;

    if (xpmPackage == null && nativePackage == null) {
      out('{@red}Package "$packageName" not found.{@end}');
      _showSuggestions(db, packageName);
      return;
    }

    out('{@blue}=== Package: $packageName ==={@end}');
    print('');

    // Show XPM package info
    if (xpmPackage != null) {
      out('{@yellow}[XPM Repository]{@end}');
      _printField('Name', xpmPackage.name);
      _printField('Title', xpmPackage.title);
      _printField('Version', xpmPackage.version);
      _printField('Description', xpmPackage.desc);
      _printField('URL', xpmPackage.url);

      if (xpmPackage.arch != null && xpmPackage.arch!.isNotEmpty) {
        _printField('Architectures', xpmPackage.arch!.join(', '));
      }

      if (xpmPackage.methods != null && xpmPackage.methods!.isNotEmpty) {
        _printField('Install Methods', xpmPackage.methods!.join(', '));
      }

      if (xpmPackage.defaults != null && xpmPackage.defaults!.isNotEmpty) {
        _printField('Default Methods', xpmPackage.defaults!.join(', '));
      }

      // Installation status
      if (xpmPackage.installed != null) {
        out('{@green}Status: Installed (${xpmPackage.installed}){@end}');
        if (xpmPackage.method != null) {
          _printField('Installed Method', xpmPackage.method);
        }
        if (xpmPackage.channel != null) {
          _printField('Installed Channel', xpmPackage.channel);
        }
      } else {
        out('{@gray}Status: Not installed{@end}');
      }

      print('');
    }

    // Show native package info
    if (nativePackage != null) {
      out('{@yellow}[Native Package Manager]{@end}');
      _printField('Name', nativePackage['name']);
      _printField('Version', nativePackage['version']);
      _printField('Description', nativePackage['description']);
      _printField('Architecture', nativePackage['arch']);
      _printField('Repository', nativePackage['repo']);

      // Check if installed natively
      final nativeManager = await NativePackageManagerDetector.detect();
      if (nativeManager != null) {
        final isInstalled = await nativeManager.isInstalled(packageName);
        if (isInstalled) {
          out('{@green}Status: Installed (native){@end}');
        } else {
          out('{@gray}Status: Available{@end}');
        }
      }
    }
  }

  Future<Map<String, String?>?> _getNativePackageInfo(String packageName) async {
    try {
      final nativeManager = await NativePackageManagerDetector.detect();
      if (nativeManager == null) return null;

      final package = await nativeManager.get(packageName);
      if (package == null) return null;

      return {
        'name': package.name,
        'version': package.version,
        'description': package.description,
        'arch': package.arch,
        'repo': package.repo,
      };
    } catch (e) {
      return null;
    }
  }

  void _printField(String label, String? value) {
    if (value != null && value.isNotEmpty) {
      out('  {@gray}$label:{@end} $value');
    }
  }

  Future<void> _showSuggestions(Isar db, String packageName) async {
    // Try to find similar packages
    final similar = await db.packages
        .filter()
        .nameContains(packageName, caseSensitive: false)
        .or()
        .descContains(packageName, caseSensitive: false)
        .limit(5)
        .findAll();

    if (similar.isNotEmpty) {
      out('');
      out('{@yellow}Did you mean:{@end}');
      for (final pkg in similar) {
        out('  - {@blue}${pkg.name}{@end} - ${pkg.title ?? pkg.desc ?? ""}');
      }
    }

    // Suggest refresh if no results
    out('');
    out('{@gray}Tip: Try running "xpm refresh" to update the package index.{@end}');
  }
}
