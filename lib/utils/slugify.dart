/// Converts a string to a slug.
///
/// The [text] parameter is the string to be converted to a slug.
///
/// Returns the slugified string.
String slugify(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

/// An extension on [String] that provides a method to convert a string to a slug.
extension Slugify on String {
  /// Converts the string to a slug.
  ///
  /// Returns the slugified string.
  String slugify() {
    return trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
