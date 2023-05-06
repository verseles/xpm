import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:xpm/utils/checksum.dart';
import 'package:xpm/utils/out.dart';
import 'package:xpm/utils/show_usage.dart';

class ChecksumCommand extends Command {
  @override
  final name = "checksum";

  @override
  final description = "Check the checksum of a file";
  @override
  final category = "For developers";
  @override
  String get invocation => '${runner!.executableName} $name <expectedHash> <file path>';
  @override
  final aliases = ['cs'];

  final Map<String, Hash> _supportedHashes = {
    'sha1': sha1,
    'sha256': sha256,
    'sha512': sha512,
    'md5': md5,
    'sha224': sha224,
    'sha384': sha384,
    'sha512-224': sha512224,
    'sha512-256': sha512256,
  };

  ChecksumCommand() {
    argParser.addOption('type',
        abbr: 't', help: 'Hash type', allowed: _supportedHashes.keys.toList(), defaultsTo: 'sha1');
  }

  @override
  void run() async {
    List<String> words = argResults!.rest;

    showUsage(words.isEmpty, () => printUsage());

    final String hashType = argResults!['type'];
    final String expectedHash = words[0];
    final String filePath = words[1];

    final Hash hasher = _supportedHashes[hashType]!;
    final file = File(filePath);

    var checksum = Checksum();
    final bool result = await checksum.check(file, hasher, expectedHash);

    if (result) {
      out('{@green}✅ Checksum is correct:{@end} {@green}$expectedHash{@end}');
    } else {
      out('{@red}⛔ Checksum is incorrect{@end}: {@yellow}$expectedHash{@end} != {@green}${checksum.fileHash}{@end}');
    }
  }
}
