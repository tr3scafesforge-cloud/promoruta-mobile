import 'package:flutter_test/flutter_test.dart';
import 'package:promoruta/core/models/version_info.dart';

void main() {
  group('VersionInfo', () {
    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        final json = {
          'version': '1.2.3',
          'buildNumber': 42,
          'downloadUrl': 'https://example.com/app.apk',
          'releaseDate': '2024-01-15T10:30:00Z',
          'releaseNotes': 'Bug fixes and improvements',
          'minSupportedVersion': '1.0.0',
        };

        final versionInfo = VersionInfo.fromJson(json);

        expect(versionInfo.version, equals('1.2.3'));
        expect(versionInfo.buildNumber, equals(42));
        expect(versionInfo.downloadUrl, equals('https://example.com/app.apk'));
        expect(versionInfo.releaseDate, equals(DateTime.parse('2024-01-15T10:30:00Z')));
        expect(versionInfo.releaseNotes, equals('Bug fixes and improvements'));
        expect(versionInfo.minSupportedVersion, equals('1.0.0'));
      });

      test('should parse JSON without optional fields', () {
        final json = {
          'version': '1.0.0',
          'buildNumber': 1,
          'downloadUrl': 'https://example.com/app.apk',
          'releaseDate': '2024-01-01T00:00:00Z',
        };

        final versionInfo = VersionInfo.fromJson(json);

        expect(versionInfo.version, equals('1.0.0'));
        expect(versionInfo.buildNumber, equals(1));
        expect(versionInfo.releaseNotes, isNull);
        expect(versionInfo.minSupportedVersion, isNull);
      });
    });

    group('toJson', () {
      test('should serialize all fields correctly', () {
        final versionInfo = VersionInfo(
          version: '2.0.0',
          buildNumber: 100,
          downloadUrl: 'https://example.com/app-v2.apk',
          releaseDate: DateTime.parse('2024-06-01T12:00:00Z'),
          releaseNotes: 'New features',
          minSupportedVersion: '1.5.0',
        );

        final json = versionInfo.toJson();

        expect(json['version'], equals('2.0.0'));
        expect(json['buildNumber'], equals(100));
        expect(json['downloadUrl'], equals('https://example.com/app-v2.apk'));
        expect(json['releaseDate'], equals('2024-06-01T12:00:00.000Z'));
        expect(json['releaseNotes'], equals('New features'));
        expect(json['minSupportedVersion'], equals('1.5.0'));
      });

      test('should not include null optional fields', () {
        final versionInfo = VersionInfo(
          version: '1.0.0',
          buildNumber: 1,
          downloadUrl: 'https://example.com/app.apk',
          releaseDate: DateTime.parse('2024-01-01T00:00:00Z'),
        );

        final json = versionInfo.toJson();

        expect(json.containsKey('releaseNotes'), isFalse);
        expect(json.containsKey('minSupportedVersion'), isFalse);
      });
    });

    group('isNewerVersion', () {
      test('should return true when major version is higher', () {
        expect(VersionInfo.isNewerVersion('1.0.0', '2.0.0'), isTrue);
        expect(VersionInfo.isNewerVersion('1.9.9', '2.0.0'), isTrue);
        expect(VersionInfo.isNewerVersion('0.9.9', '1.0.0'), isTrue);
      });

      test('should return true when minor version is higher', () {
        expect(VersionInfo.isNewerVersion('1.0.0', '1.1.0'), isTrue);
        expect(VersionInfo.isNewerVersion('1.0.9', '1.1.0'), isTrue);
        expect(VersionInfo.isNewerVersion('2.5.0', '2.6.0'), isTrue);
      });

      test('should return true when patch version is higher', () {
        expect(VersionInfo.isNewerVersion('1.0.0', '1.0.1'), isTrue);
        expect(VersionInfo.isNewerVersion('1.0.5', '1.0.6'), isTrue);
        expect(VersionInfo.isNewerVersion('2.3.9', '2.3.10'), isTrue);
      });

      test('should return false when versions are equal', () {
        expect(VersionInfo.isNewerVersion('1.0.0', '1.0.0'), isFalse);
        expect(VersionInfo.isNewerVersion('2.5.3', '2.5.3'), isFalse);
      });

      test('should return false when current is newer', () {
        expect(VersionInfo.isNewerVersion('2.0.0', '1.0.0'), isFalse);
        expect(VersionInfo.isNewerVersion('1.5.0', '1.4.0'), isFalse);
        expect(VersionInfo.isNewerVersion('1.0.5', '1.0.4'), isFalse);
      });

      test('should handle two-digit version numbers correctly', () {
        expect(VersionInfo.isNewerVersion('1.9.0', '1.10.0'), isTrue);
        expect(VersionInfo.isNewerVersion('1.10.0', '1.9.0'), isFalse);
        expect(VersionInfo.isNewerVersion('1.0.9', '1.0.10'), isTrue);
        expect(VersionInfo.isNewerVersion('1.0.10', '1.0.9'), isFalse);
      });

      test('should handle partial version strings', () {
        expect(VersionInfo.isNewerVersion('1.0', '1.1'), isTrue);
        expect(VersionInfo.isNewerVersion('1', '2'), isTrue);
        expect(VersionInfo.isNewerVersion('1.0.0', '1.0'), isFalse);
        expect(VersionInfo.isNewerVersion('1.0', '1.0.0'), isFalse);
      });

      test('should handle edge cases', () {
        expect(VersionInfo.isNewerVersion('0.0.0', '0.0.1'), isTrue);
        expect(VersionInfo.isNewerVersion('0.0.1', '0.0.0'), isFalse);
        expect(VersionInfo.isNewerVersion('', '1.0.0'), isTrue);
        expect(VersionInfo.isNewerVersion('1.0.0', ''), isFalse);
      });
    });
  });
}
