/// A boolean value indicating whether the current environment is a Snap environment.
bool _hasSnap = false;

/// A boolean value indicating whether the current environment is a Flatpak environment.
bool _hasFlatpak = false;

/// A boolean value indicating whether the current environment is an AppImage environment.
bool _hasAppImage = false;

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
      _hasAppImage = false;
    }
  }

  /// Gets or sets a value indicating whether the current environment is a Flatpak environment.
  static bool get hasFlatpak => _hasFlatpak;
  static set hasFlatpak(bool value) {
    _hasFlatpak = value;
    if (value) {
      _hasSnap = false;
      _hasAppImage = false;
    }
  }

  /// Gets or sets a value indicating whether the current environment is an AppImage environment.
  static bool get hasAppImage => _hasAppImage;
  static set hasAppImage(bool value) {
    _hasAppImage = value;
    if (value) {
      _hasSnap = false;
      _hasFlatpak = false;
    }
  }

  /// Gets or sets the path to the sudo command.
  static String get sudoPath => _sudoPath;
  static set sudoPath(String value) => _sudoPath = value;

  static String get updateCommand => _updateCommand;
  static set updateCommand(String value) => _updateCommand = value;
}
