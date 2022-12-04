String slugify(String text) {
  return text
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
}

// another way: extend the String class
extension Slugify on String {
  String slugify() {
    return trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }
}
