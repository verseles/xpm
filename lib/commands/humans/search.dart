import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/native/models/native_package.dart';
import 'package:xpm/os/get_archicteture.dart';
import 'package:xpm/native/native_package_manager.dart';
import 'package:xpm/os/native_manager_detector.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class SearchCommand extends Command {
  Future<NativePackageManager?> Function() nativePackageManager =
      detectNativeManager;
  void Function(String) printer = out;

  @override
  final name = "search";
  @override
  final aliases = ['s', 'find'];
  @override
  final description = "Search for a package";
  @override
  final category = "For humans";

  SearchCommand() {
    argParser.addFlag(
      'exact',
      negatable: false,
      abbr: 'e',
      help: 'Search for an exact match of the package name.',
    );
    argParser.addFlag(
      'all',
      negatable: false,
      abbr: 'a',
      help: 'List all packages available.',
    );
    argParser.addOption(
      'native',
      abbr: 'n',
      allowed: ['auto', 'only', 'off'],
      defaultsTo: 'auto',
      help: 'Control the use of the native package manager.',
    );
    argParser.addOption(
      'limit',
      abbr: 'l',
      defaultsTo: '20',
      help: 'Limit the number of results.',
    );
  }

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    {
      final exact = argResults!['exact'] as bool;
      final all = argResults!['all'] as bool;
      final nativeMode = argResults!['native'] as String;
      final limit = int.tryParse(argResults!['limit']) ?? 20;

      final words = argResults!.rest;

      showUsage(words.isEmpty && !all, printUsage);

      final db = await DB.instance();
      var results = <Package>[];
      var nativeResults = <NativePackage>[];

      if (nativeMode != 'only') {
        if (all) {
          results = await db.packages.where().limit(limit).findAll();
        } else if (exact) {
          results = await db.packages
              .filter()
              .nameEqualTo(words[0])
              .limit(limit)
              .findAll();
        } else {
          results = await db.packages
              .filter()
              .anyOf(
                words,
                (q, w) => q.nameMatches('*$w*', caseSensitive: false),
              )
              .or()
              .anyOf(
                words,
                (q, w) => q.descMatches('*$w*', caseSensitive: false),
              )
              .or()
              .anyOf(
                words,
                (q, w) => q.titleMatches('*$w*', caseSensitive: false),
              )
              .sortByName()
              .thenByTitle()
              .thenByDesc()
              .limit(limit)
              .findAll();
        }
      }

      if (nativeMode != 'off' && (nativeMode == 'only' || results.length < 6)) {
        final nativeManager = await nativePackageManager();
        if (nativeManager != null) {
          nativeResults = await nativeManager.search(
            words.join(' '),
            limit: limit,
          );
        }
      }

      final currentArch = getArchitecture();
      final currentOS = Platform.operatingSystem;
      final platform = "$currentOS-$currentArch";

      if (results.isEmpty && nativeResults.isEmpty) {
        print('No packages found.');
      } else {
        print('Found ${results.length + nativeResults.length} packages:');
        for (final result in results) {
          final installed = result.installed != null
              ? '[{@green}installed{@end}] '
              : '';
          final unavailable =
              result.arch != null &&
                  !result.arch!.contains('any') &&
                  !result.arch!.contains(platform)
              ? '[{@red}unavailable for $platform{@end}]'
              : '';

          _printPackage(result, platform);
        }

        for (final result in nativeResults) {
          _printNativePackage(result);
        }
      }
    }
  }

  void _printPackage(Package package, String platform) {
    final installed = package.installed != null;
    final unavailable =
        package.arch != null &&
            !package.arch!.contains('any') &&
            !package.arch!.contains(platform);

    printer(
      '${unavailable ? '[@{red}unavailable for $platform{@end}]' : ''}{@blue}${package.name}{@end} {@green}${package.version}{@end} ${installed ? '[@{green}installed{@end}] ' : ''}- ${package.title != package.name ? "${package.title} - " : ""}${package.desc}',
    );
  }

  void _printNativePackage(NativePackage package) {
    final installed = package.isInstalled ? '[{@green}installed{@end}] ' : '';
    printer(
      '{@cyan}[APT]{@end} {@blue}${package.name}{@end} {@green}${package.version ?? ''}{@end} $installed- ${package.description ?? ''}',
    );
  }
}
