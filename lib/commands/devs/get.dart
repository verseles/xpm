import 'package:args/command_runner.dart';

class GetCommand extends Command {
  @override
  final name = "get";
  @override
  final aliases = ['download'];
  @override
  final description = "Download file from the internet";
  @override
  final category = "For developers";

  GetCommand() {
    argParser.addFlag('sha1', abbr: '1', negatable: false, help: 'Inform SHA1 hash of the file to be checked');
    argParser.addFlag('sha256', abbr: '2', negatable: false, help: 'Inform SHA256 hash of the file to be checked');
    argParser.addFlag('sha512', abbr: '3', negatable: false, help: 'Inform SHA512 hash of the file to be checked');
  }

  // [run] may also return a Future.
  @override
  void run() {
    // print(argResults!['all']);
  }
}
