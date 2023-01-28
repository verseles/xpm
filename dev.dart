// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:xpm/os/downloader/adapters/aria2.dart';
import 'package:xpm/os/downloader/adapters/axel.dart';
import 'package:xpm/os/downloader/adapters/curl.dart';
import 'package:xpm/os/downloader/adapters/dio.dart';
import 'package:xpm/os/downloader/adapters/wget.dart';
import 'package:xpm/os/downloader/downloader.dart';

Future<void> main() async {
  const mb1 = 'https://proof.ovh.net/files/1Mb.dat';
  const mb10 = 'https://proof.ovh.net/files/10Mb.dat';
  const mb100 = 'https://proof.ovh.net/files/100Mb.dat';
  const gb1 = 'https://proof.ovh.net/files/1Gb.dat';
  const gb10 = 'https://proof.ovh.net/files/10Gb.dat';

  final url = mb10;
  final destination = File('/home/helio/download.dat');

  // final adapter = Aria2Adapter();
  // final adapter = CurlAdapter();
  // final adapter = WgetAdapter();
  // final adapter = DioAdapter();
  final adapter = AxelAdapter();

  var downloader = Downloader(adapter);

  return await downloader.download(
      url: url,
      destination: destination,
      segments: 3,
      onProgress: (progress) {
        print('PROGRESS: $progress');
      });
}
