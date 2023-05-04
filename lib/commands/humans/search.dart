import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/os/get_archicteture.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

/// A command that searches for a package.
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
    // Add options and flags for the command.
    argParser.addFlag('exact',
        negatable: false,
        abbr: 'e',
        help: 'Search for an exact match of the package name.');

    argParser.addFlag('all',
        negatable: false, abbr: 'a', help: 'List all packages available.');
  }

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    // Get the search parameters.
    bool exact = argResults!['exact'];
    bool all = argResults!['all'];
    List<String> words = argResults!.rest;

    showUsage(words.isEmpty && !all, () => printUsage());

    // Get the local database instance.
    final db = await DB.instance();
    final List<Package> results;

    // Search for packages based on the search parameters.
    if (all) {
      results = await db.packages.where().findAll();
    } else if (exact) {
      results = await db.packages.filter().nameEqualTo(words[0]).findAll();
    } else {
      results = await db.packages
          .filter()
          .anyOf(words, (q, w) => q.nameMatches('*$w*', caseSensitive: false))
          .or()
          .anyOf(words, (q, w) => q.descMatches('*$w*', caseSensitive: false))
          .or()
          .anyOf(
              words, (q, w) => q.titleMatches('*$w*', caseSensitive: false))
          .sortByName()
          .thenByTitle()
          .thenByDesc()
          .findAll();
    }

    // Get the current platform.
    final currentArch = getArchitecture();
    final currentOS = Platform.operatingSystem;
    final platform = "$currentOS-$currentArch";

    // Print the search results.
    if (results.isEmpty) {
      print('No packages found.');
    } else {
      print('Found ${results.length} packages:');
      for (final result in results) {
        final installed =
            result.installed != null ? '[{@green}installed{@end}] ' : '';
        final unavailable =
            result.arch != null && !result.arch!.contains(platform)
                ? '[{@red}unavailable for $platform{@end}] '
                : '';

        out('$unavailable{@blue}${result.name}{@end} {@gray}${result.version}{@end} $installed- ${result.desc}');
      }
    }
  }
}

