import 'package:args/command_runner.dart';
import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
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
    argParser.addFlag('exact',
        negatable: false,
        abbr: 'e',
        help: 'Search for an exact match of the package name.');
  }

  // [run] may also return a Future.
  @override
  void run() async {
    {
      bool exact = argResults!['exact'];

      List<String> words = argResults!.rest;

      showUsage(words.isEmpty, () => printUsage());

      final db = await DB.instance();

      final List<Package> results;
      if (exact) {
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

      if (results.isEmpty) {
        print('No packages found.');
      } else {
        print('Found ${results.length} packages:');
        for (final result in results) {
          out('{@blue}${result.name}{@end} {@gray}${result.version}{@end} - ${result.desc}');
        }
      }
    }
  }
}
