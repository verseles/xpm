import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
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
  }

  // [run] may also return a Future.
  @override
  Future<void> run() async {
    {
      bool exact = argResults!['exact'];
      bool all = argResults!['all'];

      List<String> words = argResults!.rest;

      showUsage(words.isEmpty && !all, () => printUsage());

      final db = await DB.instance();
      final List<Package> results;

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
            .anyOf(words, (q, w) => q.titleMatches('*$w*', caseSensitive: false))
            .sortByName()
            .thenByTitle()
            .thenByDesc()
            .findAll();
      }

      final currentArch = getArchitecture();
      final currentOS = Platform.operatingSystem;
      final platform = "$currentOS-$currentArch";

      if (results.isEmpty) {
        print('No packages found.');
      } else {
        print('Found ${results.length} packages:');
        for (final result in results) {
          final installed = result.installed != null ? '[{@green}installed{@end}] ' : '';
          final unavailable =
              result.arch != null && !result.arch!.contains(platform) ? '[{@red}unavailable for $platform{@end}] ' : '';

          print(result.methods);
          out('$unavailable{@blue}${result.name}{@end} {@green}${result.version}{@end} $installed- ${result.desc}');
        }
      }
    }
  }
}
