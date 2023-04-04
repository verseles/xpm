import 'package:test/test.dart';
import 'package:xpm/setting.dart';

void main() {
  group('Setting', () {
    // tearDown removes any settings that were created during the test
    tearDown(() async {
      await Setting.delete([
        'greeting',
        'missing',
        'deleteme',
        'deleteme1',
        'deleteme2',
        'deleteme3'
      ]);
    });
    test('set and get a setting value', () async {
      // Set the value of a setting
      await Setting.set('greeting', 'Hello, World!');

      // Get the value of the setting
      final greeting = await Setting.get('greeting');

      // Assert that the value of the setting is correct
      expect(greeting, equals('Hello, World!'));
    });

    test('delete a setting', () async {
      // Set the value of a setting
      await Setting.set('greeting', 'Hello, World!');

      // Delete the setting
      await Setting.delete('greeting');

      // Get the value of the setting
      final greeting = await Setting.get('greeting');

      // Assert that the value of the setting is null (it doesn't exist)
      expect(greeting, isNull);
    });

    test('get a default value for a missing setting', () async {
      // Get the value of a non-existent setting with a default value
      final missing = await Setting.get('missing', defaultValue: 'default');

      // Assert that the value of the setting is the default value
      expect(missing, equals('default'));
    });

    test('cache a setting value', () async {
      // Set the value of a setting
      await Setting.set('greeting', 'Hello, World!');

      // Get the value of the setting twice (to test caching)
      final greeting1 = await Setting.get('greeting');
      final greeting2 = await Setting.get('greeting');

      // Assert that the value of the setting is correct and was only queried once
      expect(greeting1, equals('Hello, World!'));
      expect(greeting2, equals('Hello, World!'));
    }, tags: ['not-tested']);

    test('delete a just created setting', () async {
      // Set the value of a setting
      await Setting.set('deleteme', 'I should be deleted');

      // Delete the setting
      await Setting.delete('deleteme');

      // Get the value of the setting
      final deleteme = await Setting.get('deleteme');

      // Assert that the value of the setting is null (it doesn't exist)
      expect(deleteme, isNull);
    });
    test('delete a List of keys of settings', () async {
      // Set the value of a setting
      await Setting.set('deleteme1', 'I should be deleted');
      await Setting.set('deleteme2', 'I should be deleted');
      await Setting.set('deleteme3', 'I should be deleted');

      // Delete the list of settings
      await Setting.delete(['deleteme1', 'deleteme2', 'deleteme3']);

      // Get the value of the setting
      final deleteme2 = await Setting.get('deleteme2');

      // Assert that the value of the setting is null (it doesn't exist)
      expect(deleteme2, isNull);
    });

    test('delete expired settings imeadiately', () async {
      // Set the value of a setting with an expiration date of 1 second
      final now = DateTime.now();
      final expireTime = now.add(Duration(seconds: 1));
      await Setting.set('expireme', 'I should be deleted after 1 second',
          expires: expireTime);

      // Wait for the setting to expire
      await Future.delayed(Duration(seconds: 2));

      // Delete expired settings
      await Setting.deleteExpired();

      // Get the value of the expired setting
      final expired = await Setting.get('expireme', cache: false);

      // Assert that the value of the expired setting is null (it was deleted)
      expect(expired, isNull);
    });

    test('delete expired settings at the end of the executation', () async {
      // Set the value of a setting with an expiration date of 1 second
      final now = DateTime.now();
      final expireTime = now.add(Duration(seconds: 1));
      final value = 'I should exist in this test';
      await Setting.set('expireme', value, expires: expireTime);

      // Wait for the setting to expire
      await Future.delayed(Duration(seconds: 2));

      // Delete expired settings (lazy)
      await Setting.deleteExpired(lazy: true);

      // Get the value of the expired setting
      final expired = await Setting.get('expireme', cache: false);

      // Assert that the value still there
      expect(expired, equals(value));
    });
  });
}
