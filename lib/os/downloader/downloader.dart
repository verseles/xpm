import 'dart:io';

import 'package:xpm/os/downloader/downloader_adapter.dart';

class Downloader {
  static String userAgent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36';

  Function(double, int)? onProgress;
  Function(Error)? onError;
  DownloaderAdapter adapter;

  Downloader(this.adapter);

  Future<void> download(
      {required String url,
      required File destination,
      int? segments,
      Function(Map<String, dynamic>)? onProgress,
      Function(Error)? onError}) async {

    if (!adapter.isAvailable) {
      throw Exception('Downloader adapter ${adapter.executable.cmd} not available');
    }

    segments ??= 1;
    if (url.isEmpty) {
      throw Exception('URL not provided');
    }
    try {
      await adapter.download(url: url, destination: destination, segments: segments, onProgress: onProgress);
    } on Error catch (e) {
      if (onError != null) {
        onError(e);
      } else {
        rethrow;
      }
    }
  }
}
