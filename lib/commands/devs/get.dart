import 'dart:io';
import 'dart:typed_data';
import 'package:all_exit_codes/all_exit_codes.dart';
import 'package:crypto/crypto.dart';

import 'package:args/command_runner.dart';
import 'package:dloader/dloader.dart';

import 'package:interact/interact.dart' show Progress, Theme;
import 'package:xpm/os/move_to_bin.dart';
import 'package:xpm/os/run.dart';
import 'package:xpm/utils/logger.dart';
import 'package:xpm/utils/show_usage.dart';
import 'package:xpm/xpm.dart';

class GetCommand extends Command {
  @override
  final name = "get";
  @override
  final description = "Download file from the internet";
  @override
  final category = "For developers";
  @override
  final invocation = "xpm get <url>";

  GetCommand() {
    argParser.addOption("out",
        abbr: "o", help: "Output file path with filename", valueHelp: 'path');

    argParser.addOption('name',
        abbr: 'n',
        help: 'Define the name of the downloaded file without defining the path'
            ' (only works with --out)');

    argParser.addFlag('exec',
        abbr: 'x',
        help: 'Make executable the downloaded file (unix only)',
        negatable: false);

    argParser.addFlag('bin',
        abbr: 'b',
        help: 'Install to bin folder of the system',
        negatable: false);

    argParser.addOption('md5', help: 'Check MD5 hash', valueHelp: 'hash');
    argParser.addOption('sha1', help: 'Check SHA1 hash', valueHelp: 'hash');
    argParser.addOption('sha256', help: 'Check SHA256 hash', valueHelp: 'hash');
    argParser.addOption('sha512', help: 'Check SHA512 hash', valueHelp: 'hash');
    argParser.addOption('sha224', help: 'Check SHA224 hash', valueHelp: 'hash');
    argParser.addOption('sha384', help: 'Check SHA384 hash', valueHelp: 'hash');
    argParser.addOption('sha512-224',
        help: 'Check SHA512/224 hash', valueHelp: 'hash');
    argParser.addOption('sha512-256',
        help: 'Check SHA512/256 hash', valueHelp: 'hash');
  }

  @override
  void run() async {
    showUsage(argResults!.rest.isEmpty, () => printUsage());

    final String url = argResults!.rest[0];

    final Aria2Adapter aria2Adapter = Aria2Adapter();
    final CurlAdapter curlAdapter = CurlAdapter();
    final WgetAdapter wgetAdapter = WgetAdapter();
    final DioAdapter dioAdapter = DioAdapter();

    late final DloaderAdapter adapter;

    if (aria2Adapter.isAvailable) {
      adapter = aria2Adapter;
    } else if (curlAdapter.isAvailable) {
      adapter = curlAdapter;
    } else if (wgetAdapter.isAvailable) {
      adapter = wgetAdapter;
    } else {
      adapter = dioAdapter;
    }

    final downloader = Dloader(adapter);

    Uri uri = Uri.parse(url);
    // if no filename in url, generate one randomly
    String fileName;
    if (argResults!['name'] != null) {
      fileName = argResults!['name'];
    } else if (uri.pathSegments.isNotEmpty) {
      fileName = uri.pathSegments.last;
    } else {
      fileName = 'file-${DateTime.now().millisecondsSinceEpoch}';
    }

    File destination;
    if (argResults!["out"] != null) {
      destination = File(argResults!["out"]);
      fileName = destination.path.split("/").last;
    } else {
      Directory tempDir = await XPM.temp('');
      destination = File(tempDir.path + fileName);
    }

    final progressBar = Progress.withTheme(
        theme: Theme.colorfulTheme,
        length: 100,
        rightPrompt: (current) => ' ${current.toString().padLeft(3)}%',
        leftPrompt: (c) => 'Downloading $fileName ').interact();

    final File file = await downloader.download(
      url: url,
      destination: destination,
      onProgress: (progress) {
        if (progress['percentComplete'] != null) {
          progressBar.clear();
          progressBar.increase(int.parse(progress['percentComplete']));
        }
      },
    );

    progressBar.done();

    String? expectedHash;
    Digest? fileHash;
    final Uint8List asBytes = await file.readAsBytes();

    if (argResults!['sha1'] != null) {
      expectedHash = argResults!['sha1'];
      fileHash = sha1.convert(asBytes);
    } else if (argResults!['sha256'] != null) {
      expectedHash = argResults!['sha256'];
      fileHash = sha256.convert(asBytes);
    } else if (argResults!['sha512'] != null) {
      expectedHash = argResults!['sha512'];
      fileHash = sha512.convert(asBytes);
    } else if (argResults!['md5'] != null) {
      expectedHash = argResults!['md5'];
      fileHash = md5.convert(asBytes);
    } else if (argResults!['sha224'] != null) {
      expectedHash = argResults!['sha224'];
      fileHash = sha224.convert(asBytes);
    } else if (argResults!['sha384'] != null) {
      expectedHash = argResults!['sha384'];
      fileHash = sha384.convert(asBytes);
    } else if (argResults!['sha512-224'] != null) {
      expectedHash = argResults!['sha512-224'];
      fileHash = sha512224.convert(asBytes);
    } else if (argResults!['sha512-256'] != null) {
      expectedHash = argResults!['sha512-256'];
      fileHash = sha512256.convert(asBytes);
    }

    if (fileHash != null && fileHash.toString() != expectedHash) {
      throw Exception('Hash expected $expectedHash, but got $fileHash');
    }

    final runner = Run();

    if (argResults!['bin'] == true) {
      final File? toBin = await moveToBin(file, runner: runner, sudo: true);

      if (toBin != null) {
        Logger.info('Installed $file to bin folder: ${toBin.path}');
      } else {
        throw Exception('Failed to install $file to bin folder');
      }
    }

    if (argResults!['exec'] == true && !Platform.isWindows) {
      bool asExec = await runner.asExec(file.path, sudo: true);
      if (asExec) {
        Logger.info('Made $file executable');
      } else {
        throw Exception('Failed to make $file executable');
      }
    }

    print(file.absolute.path);
    exit(success);
  }
}
