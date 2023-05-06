import 'dart:io';

/// Shows usage information and exits the program.
///
/// The [show] parameter indicates whether to show the usage information. If it is `false`, the function returns without doing anything.
///
/// The [callback] parameter is a function that is called to display the usage information. It should print the usage information to the console.
void showUsage(bool show, Function callback) {
  if (!show) {
    return;
  }

  callback();

  exit(64);
}

