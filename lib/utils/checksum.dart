import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A class for checking the checksum of a given file.
class Checksum {
  /// The hash of the file.
  Digest? fileHash;

  /// Checks the checksum of the given `file` using the specified `type` of hash and compares it to the `expectedHash`.
  /// Returns a `Future<bool>` indicating if the file's hash matches the expected hash.
  Future<bool> check(File file, Hash type, String expectedHash) async {
    final Uint8List asBytes = await file.readAsBytes();
    fileHash = type.convert(asBytes);

    return fileHash.toString() == expectedHash;
  }
}
