import 'package:test/test.dart';
import 'package:xpm/utils/json.dart';

void main() {
  group('Serialization', () {
    test('Serialize and unserialize a Map', () {
      Map<String, dynamic> data = {
        'name': 'John',
        'age': 30,
        'isMarried': true,
        'hobbies': ['reading', 'coding', 'playing guitar']
      };

      String serializedData = serialize(data);
      expect(
          serializedData, '{"name":"John","age":30,"isMarried":true,"hobbies":["reading","coding","playing guitar"]}');

      dynamic unserializedData = unserialize(serializedData);
      expect(unserializedData, equals(data));
    });

    test('Serialize and unserialize a List', () {
      List<int> numbers = [1, 2, 3, 4, 5];

      String serializedData = serialize(numbers);
      expect(serializedData, equals('[1,2,3,4,5]'));

      dynamic unserializedData = unserialize(serializedData);
      expect(unserializedData, equals(numbers));
    });
  });
}
