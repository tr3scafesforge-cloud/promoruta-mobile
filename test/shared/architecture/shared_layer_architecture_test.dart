import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shared architecture', () {
    test('shared layer does not import feature domain files', () async {
      final sharedDir = Directory('lib/shared');
      final violations = <String>[];
      final forbiddenImport = RegExp(
        r"package:promoruta/features/[^']+/domain/",
      );

      await for (final entity in sharedDir.list(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final content = await entity.readAsString();
        if (forbiddenImport.hasMatch(content)) {
          violations.add(entity.path.replaceAll(r'\', '/'));
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'Shared files importing feature domains: ${violations.join(', ')}',
      );
    });

    test('legacy presentation directory has been removed', () {
      expect(Directory('lib/presentation').existsSync(), isFalse);
    });

    test('test files are not stored under lib', () {
      final libDir = Directory('lib');
      final violations = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('_test.dart'))
          .map((file) => file.path.replaceAll(r'\', '/'))
          .toList();

      expect(
        violations,
        isEmpty,
        reason: 'Test files found under lib: ${violations.join(', ')}',
      );
    });
  });
}
