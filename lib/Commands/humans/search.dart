import 'package:args/command_runner.dart';

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
    // argParser.addFlag('all', abbr: 'a');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
