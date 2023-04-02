import 'dart:convert';

/// Serialize data into a JSON string.
///
/// Converts a Dart object into its equivalent JSON representation and returns
/// the resulting JSON string.
///
/// Usage:
///
/// ```dart
/// Map<String, dynamic> data = {
///   'name': 'John',
///   'age': 30,
///   'isMarried': true,
///   'hobbies': ['reading', 'coding', 'playing guitar']
/// };
///
/// String serializedData = serialize(data);
/// print(serializedData); // Output: {"name":"John","age":30,"isMarried":true,"hobbies":["reading","coding","playing guitar"]}
/// ```
String serialize(dynamic data) {
  return json.encode(data);
}

/// Unserialize a JSON string into a Dart object.
///
/// Parses the JSON-encoded string and converts it back into a Dart object.
///
/// Usage:
///
/// ```dart
/// String serializedData = '{"name":"John","age":30,"isMarried":true,"hobbies":["reading","coding","playing guitar"]}';
///
/// dynamic unserializedData = unserialize(serializedData);
/// print(unserializedData); // Output: { name: John, age: 30, isMarried: true, hobbies: [reading, coding, playing guitar] }
/// ```
dynamic unserialize(String data) {
  return json.decode(data);
}
