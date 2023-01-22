import 'package:args/command_runner.dart';
import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';

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
  void run() async {


      final storageIO = InternetFileStorageIO();

      await InternetFile.get(
        'https://speed.hetzner.de/1GB.bin',
        storage: storageIO,
        storageAdditional: storageIO.additional(
          filename: 'ui_icons.ttf',
          location: '',
        ),
        force: true,
        progress: (receivedLength, contentLength) {
          final percentage = receivedLength / contentLength * 100;
          print(
              'download progress: $receivedLength of $contentLength ($percentage%)');
        },
      );
  }
}
