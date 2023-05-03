/// An extension on [List<String>] that provides a method to standardize the strings in the list.
extension ListStringExtensions on List<String> {

  
  /// Replaces substrings in the strings in the list according to a map of correspondences.
  ///
  /// The [correspondences] map should have keys that represent the substrings to be replaced and values that represent the replacement substrings.
  ///
  /// Returns a new list with the standardized strings.
  List<String> standardize(Map<String, String> correspondences) {
    List<String> newValues = [];
    forEach((value) {
      correspondences.forEach((key, newValue) {
        value = value.replaceAll(key, newValue);
      });
      newValues.add(value);
    });
    return newValues;
  }
}

