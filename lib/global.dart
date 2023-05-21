/// A boolean value indicating whether the current environment is a Snap environment.
bool _hasSnap = false;

/// A boolean value indicating whether the current environment is a Flatpak environment.
bool _hasFlatpak = false;

/// The path to the sudo command.
String _sudoPath = '';

String _updateCommand = '';

/// A class that provides global variables and methods.
class Global {
  /// Gets or sets a value indicating whether the current environment is a Snap environment.
  static bool get hasSnap => _hasSnap;
  static set hasSnap(bool value) {
    _hasSnap = value;
    if (value) {
      _hasFlatpak = false;
    }
  }

  /// Gets or sets a value indicating whether the current environment is a Flatpak environment.
  static bool get hasFlatpak => _hasFlatpak;
  static set hasFlatpak(bool value) {
    _hasFlatpak = value;
    if (value) {
      _hasSnap = false;
    }
  }

  /// Gets or sets the path to the sudo command.
  static String get sudoPath => _sudoPath;
  static set sudoPath(String value) => _sudoPath = value;

  static String get updateCommand => _updateCommand;
  static set updateCommand(String value) => _updateCommand = value;
}
