import 'dart:io';

import 'package:dio/dio.dart';
import 'package:xpm/os/downloader/downloader_adapter.dart';
import 'package:xpm/os/executable.dart';

class DioAdapter implements DownloaderAdapter {
  @override
  Executable executable = Executable('cp');

  @override
  late final bool isAvailable;

  @override
  late final String executablePath;

  DioAdapter() {
    isAvailable = true;
  }

  @override
  Future<File> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress}) async {
    final dio = Dio();
    try {
      await dio.download(url, destination.path, onReceiveProgress: (received, total) {
        final Map<String, String> progress = {};
        if (total != -1) {
          progress['percentComplete'] = (received / total * 100).toStringAsFixed(0);
          progress['downloaded'] = received.toString();
          progress['totalSize'] = total.toString();
          onProgress?.call(progress);
        }
      });
    } catch (e) {
      throw Exception(e);
    }

    return destination;
  }
}
