import 'dart:io';

import 'package:xpm/os/executable.dart';

abstract class DownloaderAdapter {
  late final Executable executable;
  late final bool isAvailable;
  late final String executablePath;

  Future<File> download({required String url, required File destination, int? segments, Function(Map<String, dynamic>)? onProgress});
}
