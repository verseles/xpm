import 'package:test/test.dart';
import 'package:xpm/native/apt_package_manager.dart';
import 'package:mockito/mockito.dart';
import 'package:xpm/native/models/native_package.dart';
import 'package:xpm/os/run.dart';
import 'package:mockito/annotations.dart';
import 'dart:io';

@GenerateMocks([Run])
import 'apt_package_manager_test.mocks.dart';

void main() {
  late AptPackageManager aptPackageManager;
  late MockRun mockRun;

  setUp(() {
    mockRun = MockRun();
    aptPackageManager = AptPackageManager(runner: mockRun);
  });

  group('AptPackageManager', () {
    test('search returns a list of packages', () async {
      when(mockRun.simple('apt-cache', ['search', 'git'])).thenAnswer(
        (_) async => ProcessResult(
          0,
          0,
          'git - fast, scalable, distributed revision control system',
          null,
        ),
      );
      when(mockRun.simple('apt-cache', ['show', 'git'])).thenAnswer(
        (_) async => ProcessResult(
          0,
          0,
          'Version: 1:2.34.1-1ubuntu1.10\nDescription-en: fast, scalable, distributed revision control system\n',
          null,
        ),
      );
      when(
        mockRun.simple('dpkg-query', ['-W', '-f=\'\'', 'git']),
      ).thenAnswer((_) async => ProcessResult(1, 1, '', null));

      final packages = await aptPackageManager.search('git');

      expect(packages, isA<List<NativePackage>>());
      expect(packages.first.name, 'git');
      expect(packages.first.version, '1:2.34.1-1ubuntu1.10');
      expect(
        packages.first.description,
        'fast, scalable, distributed revision control system',
      );
    });

    test('install calls the correct command', () async {
      when(
        mockRun.simple('apt', ['install', '-y', 'git'], sudo: true),
      ).thenAnswer((_) async => ProcessResult(0, 0, '', null));

      await aptPackageManager.install('git');

      verify(
        mockRun.simple('apt', ['install', '-y', 'git'], sudo: true),
      ).called(1);
    });

    test('isInstalled returns true when a package is installed', () async {
      when(
        mockRun.simple('dpkg-query', ['-W', '-f=\'\'', 'git']),
      ).thenAnswer((_) async => ProcessResult(0, 0, '', null));

      final isInstalled = await aptPackageManager.isInstalled('git');

      expect(isInstalled, isTrue);
    });

    test('isInstalled returns false when a package is not installed', () async {
      when(
        mockRun.simple('dpkg-query', ['-W', '-f=\'\'', 'git']),
      ).thenAnswer((_) async => ProcessResult(1, 1, '', null));

      final isInstalled = await aptPackageManager.isInstalled('git');

      expect(isInstalled, isFalse);
    });

    test('getPackageDetails returns a package when it is installed', () async {
      when(
        mockRun.simple('dpkg-query', [
          '-W',
          r'-f=${Package}\t${Version}\t${description}',
          'git',
        ]),
      ).thenAnswer(
        (_) async => ProcessResult(
          0,
          0,
          'git\t1:2.34.1-1ubuntu1.10\tfast, scalable, distributed revision control system',
          null,
        ),
      );

      final package = await aptPackageManager.getPackageDetails('git');

      expect(package, isA<NativePackage>());
      expect(package!.name, 'git');
      expect(package.version, '1:2.34.1-1ubuntu1.10');
      expect(
        package.description,
        'fast, scalable, distributed revision control system',
      );
    });

    test(
      'getPackageDetails returns null when a package is not installed',
      () async {
        when(
          mockRun.simple('dpkg-query', [
            '-W',
            r'-f=${Package}\t${Version}\t${description}',
            'git',
          ]),
        ).thenAnswer((_) async => ProcessResult(1, 1, '', null));

        final package = await aptPackageManager.getPackageDetails('git');

        expect(package, isNull);
      },
    );
  });
}
