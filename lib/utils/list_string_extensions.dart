extension ListStringExtensions on List<String> {
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
