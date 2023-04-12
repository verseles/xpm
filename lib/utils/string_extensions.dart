extension StringExtensions on String {
  String standardize(Map<String, String> correspondences) {
    String newValue = this;
    correspondences.forEach((key, value) => newValue = newValue.replaceAll(key, value));
    return newValue;
  }
}