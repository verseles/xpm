/// A boolean value indicating whether the current environment is a Snap environment.
bool _isSnap = false;

/// A boolean value indicating whether the current environment is a Flatpak environment.
bool _isFlatpak = false;

/// A boolean value indicating whether the current environment is an AppImage environment.
bool _isAppImage = false;

/// The path to the sudo command.
String _sudoPath = '';

/// A class that provides global variables and methods.
class Global {
  /// Gets or sets a value indicating whether the current environment is a Snap environment.
  static bool get isSnap => _isSnap;
  static set isSnap(bool value) {
    _isSnap = value;
    if (value) {
      _isFlatpak = false;
      _isAppImage = false;
    }
  }

  /// Gets or sets a value indicating whether the current environment is a Flatpak environment.
  static bool get isFlatpak => _isFlatpak;
  static set isFlatpak(bool value) {
    _isFlatpak = value;
    if (value) {
      _isSnap = false;
      _isAppImage = false;
    }
  }

  /// Gets or sets a value indicating whether the current environment is an AppImage environment.
  static bool get isAppImage => _isAppImage;
  static set isAppImage(bool value) {
    _isAppImage = value;
    if (value) {
      _isSnap = false;
      _isFlatpak = false;
    }
  }

  /// Gets or sets the path to the sudo command.
  static String get sudoPath => _sudoPath;
  static set sudoPath(String value) => _sudoPath = value;
}
