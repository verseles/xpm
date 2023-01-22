import 'package:internet_file/internet_file.dart';
import 'package:internet_file/storage_io.dart';

void main(List<String> args) async {

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
