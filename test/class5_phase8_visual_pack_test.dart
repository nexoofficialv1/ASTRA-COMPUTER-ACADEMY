import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all Class V lessons have mapped visual assets', () {
    final root = jsonDecode(
      File('assets/content/class5_cursor_pro.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final lessons = <Map<String, dynamic>>[];
    for (final courseRaw in root['courses'] as List<dynamic>) {
      final course = Map<String, dynamic>.from(courseRaw as Map);
      for (final lessonRaw in course['lessons'] as List<dynamic>) {
        lessons.add(Map<String, dynamic>.from(lessonRaw as Map));
      }
    }

    expect(lessons.length, 27);

    for (final lesson in lessons) {
      final id = lesson['id'] as String;
      final asset = (lesson['visualAsset'] as String?) ?? '';

      expect(asset.trim(), isNotEmpty, reason: '$id visualAsset');
      expect(File(asset).existsSync(), isTrue, reason: '$id visual file');
      expect(
        (lesson['visualCaptionBn'] as String?)?.trim(),
        isNotEmpty,
        reason: '$id Bengali visual caption',
      );
      expect(
        (lesson['visualCaptionEn'] as String?)?.trim(),
        isNotEmpty,
        reason: '$id English visual caption',
      );
    }
  });

  test('visual pack contains at least 12 PNG assets', () {
    final dir = Directory('assets/visuals/class5');
    final pngs = dir
        .listSync()
        .whereType<File>()
        .where((item) => item.path.endsWith('.png'))
        .toList();

    expect(pngs.length, greaterThanOrEqualTo(12));
  });

  test('model, screen and pubspec support visual learning', () {
    final model = File('lib/models/lesson.dart').readAsStringSync();
    final screen = File('lib/screens/lesson_screen.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(model.contains('final String visualAsset;'), isTrue);
    expect(model.contains('bool get hasVisualAsset'), isTrue);
    expect(screen.contains("'শেখার ছবি'"), isTrue);
    expect(screen.contains('Image.asset('), isTrue);
    expect(screen.contains('lesson.visualAsset'), isTrue);
    expect(pubspec.contains('assets/visuals/class5/'), isTrue);
  });
}
