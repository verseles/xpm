import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xpm/os/downloader/downloader_adapter.dart';
import 'package:xpm/os/executable.dart';

class CurlAdapter implements DownloaderAdapter {
  @override
  Executable executable = Executable('curl');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  CurlAdapter() {
    isAvailable = executable.existsSync();
  }

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    executablePath = (await executable.find())!;
    Process.start(executablePath, [
      '--create-dirs',
      '--location',
      '--output',
      destination.path,
      url
    ]).then((Process process) {
      process.stderr.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parseCurlProgress(line));
        }
      });
    });

    return destination;
  }

  Map<String, String> parseCurlProgress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(r'(\d+)\s+([\w.]+)\s+(\d+)\s+([\w.]+)\s+(\d+)\s+(\d+)\s+([\w.]+)\s+(\d+)\s+([0-9:]+)\s+([0-9:]+)\s+([0-9:]+)\s+([\w.]+)').firstMatch(progressString);
    if (match != null && match.groupCount == 12) {
      progress["percentComplete"] = match.group(1)!;
      progress["totalSize"] = match.group(2)!;
      progress["downloaded"] = match.group(3)!;
      progress["averageSpeed"] = match.group(7)!;
      progress["totalTime"] = match.group(9)!;
      progress["spentTime"] = match.group(10)!;
      progress["eta"] = match.group(11)!;
      progress["speed"] = match.group(12)!;
    }

    return progress;
  }
}
