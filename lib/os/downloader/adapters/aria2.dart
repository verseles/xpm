import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:xpm/os/downloader/downloader.dart';
import 'package:xpm/os/downloader/downloader_adapter.dart';
import 'package:xpm/os/executable.dart';
import 'package:path/path.dart' as path;

class Aria2Adapter implements DownloaderAdapter {
  @override
  Executable executable = Executable('aria2c');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  Aria2Adapter() {
    isAvailable = executable.existsSync();
  }

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    executablePath = (await executable.find())!;
    final filename = path.basename(destination.path);
    final directory = path.dirname(destination.path);

    Process.start(executablePath, [
      '--max-connection-per-server=$segments',
      '--split=$segments',
      '--min-split-size=1M',
      '--dir=$directory',
      '--out=$filename',
      '--file-allocation=falloc',
      '--user-agent=${Downloader.userAgent}',
      '--continue=true',
      '--auto-file-renaming=false',
      '--allow-overwrite=true',
      // '--download-result=full',
      '--human-readable=false',
      '--summary-interval=1',
      // '--log-level=info',
      // '--log=-',
      url
    ]).then((Process process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        final lines = data.split('\n');
        for (final line in lines) {
          onProgress?.call(parseAria2Progress(line));
        }
      });
    });

    return destination;
  }

  Map<String, String> parseAria2Progress(String progressString) {
    final Map<String, String> progress = {};
    final match = RegExp(
            r'\[#[a-f0-9]{6}\s(\d+(?:\.\d+)?[a-zA-Z]{1,3})/(\d+(?:\.\d+)?[a-zA-Z]{1,3})\((\d+)%\)\sCN:(\d+)\sDL:(\d+(?:\.\d+)?[a-zA-Z]{1,3})(?:\sETA:(\w+))?]')
        .firstMatch(progressString);
    if (match != null && match.groupCount >= 5) {
      progress["downloaded"] = match.group(1)!;
      progress["totalSize"] = match.group(2)!;
      progress["percentComplete"] = match.group(3)!;
      progress["parts"] = match.group(4)!;
      progress["speed"] = match.group(5)!;
      if (match.group(6) != null) {
        progress["eta"] = match.group(6)!;
      }
    }

    return progress;
  }
}
