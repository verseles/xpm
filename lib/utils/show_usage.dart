import 'dart:io';

void showUsage(bool show, Function callback) {
  if (!show) {
    return;
  }

  callback();

  exit(64);
}
