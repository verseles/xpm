import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xpm/os/downloader/downloader.dart';
import 'package:xpm/os/downloader/downloader_adapter.dart';
import 'package:xpm/os/executable.dart';

class WgetAdapter implements DownloaderAdapter {
  @override
  Executable executable = Executable('wget');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  WgetAdapter() {
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
      '--continue',
      '--output-document=${destination.path}',
      '--user-agent=${Downloader.userAgent}',
      '--progress=bar:force',
      url
    ]).then((Process process) {
      process.stderr.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parseWgetProgress(line));
        }
      });
    });

    return destination;
  }

  Map<String, String> parseWgetProgress(String progressString) {
    final Map<String, String> progress = {};
    final match =
        RegExp(r'.+\s+(\d+)%[^\]]+\]\s+([\w,]+)\s+([\w,]+/s)\s+(?:eta\s([\w\s]+))?').firstMatch(progressString);
    if (match != null && match.groupCount >= 3) {
      progress["percentComplete"] = match.group(1)!;
      progress["downloaded"] = match.group(2)!;
      progress["speed"] = match.group(3)!;
      if (match.group(4) != null) {
        progress["eta"] = match.group(4)!.trim();
      }
    }

    return progress;
  }
}
