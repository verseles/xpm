import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/native_is_for_everyone/models/native_package.dart';
import 'package:xpm/native_is_for_everyone/native_package_manager_detector.dart';
import 'package:xpm/os/get_archicteture.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class SearchCommand extends Command {
  @override
  final name = "search";
  @override
  final aliases = ['s', 'find'];
  @override
  final description = "Search for a package";
  @override
  final category = "For humans";

  SearchCommand() {
    argParser.addFlag('exact', negatable: false, abbr: 'e', help: 'Search for an exact match of the package name.');
    argParser.addFlag('all', negatable: false, abbr: 'a', help: 'List all packages available.');
    argParser.addOption(
      'native',
      abbr: 'n',
      allowed: ['auto', 'only', 'off'],
      defaultsTo: 'auto',
      help: 'Control integration with native package managers.',
    );
    argParser.addOption('limit', abbr: 'l', defaultsTo: '20', help: 'Limit the number of results.');
  }

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    bool exact = argResults!['exact'];
    bool all = argResults!['all'];
    String nativeMode = argResults!['native'];
    int limit = int.tryParse(argResults!['limit']) ?? 20;

    List<String> words = argResults!.rest;

    showUsage(words.isEmpty && !all, () => printUsage());

    final db = await DB.instance();
    List<Package> xpmResults = [];
    List<NativePackage> nativeResults = [];

    if (nativeMode != 'only') {
      if (all) {
        xpmResults = await db.packages.where().limit(limit).findAll();
      } else if (exact) {
        xpmResults = await db.packages.filter().nameEqualTo(words[0]).limit(limit).findAll();
      } else {
        xpmResults = await db.packages
            .filter()
            .anyOf(words, (q, w) => q.nameMatches('*$w*', caseSensitive: false))
            .or()
            .anyOf(words, (q, w) => q.descMatches('*$w*', caseSensitive: false))
            .or()
            .anyOf(words, (q, w) => q.titleMatches('*$w*', caseSensitive: false))
            .sortByName()
            .thenByTitle()
            .thenByDesc()
            .limit(limit)
            .findAll();
      }
    }

    if (nativeMode != 'off' && !all) {
      final nativeManager = await NativePackageManagerDetector.detect();
      if (nativeManager != null) {
        if (nativeMode == 'only' || (nativeMode == 'auto' && xpmResults.length < 6)) {
          nativeResults = await nativeManager.search(words.join(' '), limit: limit);
        }
      }
    }

    final currentArch = getArchitecture();
    final currentOS = Platform.operatingSystem;
    final platform = "$currentOS-$currentArch";

    if (xpmResults.isEmpty && nativeResults.isEmpty) {
      print('No packages found.');
    } else {
      print('Found ${xpmResults.length + nativeResults.length} packages:');
      for (final result in xpmResults) {
        final installed = result.installed != null ? '[{@green}installed{@end}] ' : '';
        final unavailable = result.arch != null && !result.arch!.contains('any') && !result.arch!.contains(platform)
            ? '[{@red}unavailable for $platform{@end}]'
            : '';

        out(
          '$unavailable{@blue}${result.name}{@end} {@green}${result.version}{@end} $installed- ${result.title != result.name ? "${result.title} - " : ""}${result.desc}',
        );
      }

      for (final result in nativeResults) {
        out('{@yellow}[APT]{@end} {@blue}${result.name}{@end} - ${result.description ?? ''}');
      }
    }
  }
}
