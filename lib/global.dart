bool _isSnap = false;
bool _isFlatpak = false;
bool _isAppImage = false;
String _sudoPath = '';

class Global {
  static bool get isSnap => _isSnap;
  static set isSnap(bool value) {
    _isSnap = value;
    if (value) {
      _isFlatpak = false;
      _isAppImage = false;
    }
  }

  static bool get isFlatpak => _isFlatpak;
  static set isFlatpak(bool value) {
    _isFlatpak = value;
    if (value) {
      _isSnap = false;
      _isAppImage = false;
    }
  }

  static bool get isAppImage => _isAppImage;
  static set isAppImage(bool value) {
    _isAppImage = value;
    if (value) {
      _isSnap = false;
      _isFlatpak = false;
    }
  }

  static String get sudoPath => _sudoPath;
  static set sudoPath(String value) => _sudoPath = value;
}
