import 'dart:convert';
import 'dart:io';
import 'package:xpm/os/downloader/downloader_adapter.dart';
import 'package:xpm/os/executable.dart';

class AxelAdapter implements DownloaderAdapter {
  @override
  Executable executable = Executable('axel');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  AxelAdapter() {
    isAvailable = executable.existsSync();
  }

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    executablePath = (await executable.find())!;
    var args = [url, '-o', destination.path];
    if (segments != null) {
      args.insert(1, '-n');
      args.insert(2, segments.toString());
    }
    Process.start(executablePath, args).then((Process process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parseAxelProgress(line));
        }
      });
    });

    return destination;
  }

  Map<String, dynamic> parseAxelProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(
            r'(\d+)%\s+\|\s+(\d+\.\d\w)\s+/\s+(\d+\.\d\w)\s+\|\s+(\d+\.\d\w/s)\s+\|\s+(\d+\.\d\w/s)\s+\|\s+(\d+\.\d\w)\s+\|')
        .firstMatch(progressString);
    if (match != null && match.groupCount == 7) {
      progress["percentComplete"] = match.group(1)!;
      progress["downloaded"] = match.group(2)!;
      progress["totalSize"] = match.group(3)!;
      progress["speed"] = match.group(4)!;
      progress["averageSpeed"] = match.group(5)!;
      progress["eta"] = match.group(6)!;
      progress["time"] = match.group(7)!;
    } else {
      print('NO MATCH: $progressString');

    }
    return progress;
  }
}
