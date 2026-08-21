import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all Class V mockups contain guided explanation', () {
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
      final cards = lesson['mockupCards'] as List<dynamic>;
      expect(cards, isNotEmpty, reason: id);
      final card = Map<String, dynamic>.from(cards.first as Map);

      for (final key in [
        'observeBn',
        'understandBn',
        'rememberBn',
        'observeEn',
        'understandEn',
        'rememberEn',
      ]) {
        expect(
          (card[key] as String?)?.trim(),
          isNotEmpty,
          reason: '$id $key',
        );
      }
    }
  });

  test('learning image supports full screen zoom', () {
    final zoom =
        File('lib/screens/visual_zoom_screen.dart').readAsStringSync();
    final lesson =
        File('lib/screens/lesson_screen.dart').readAsStringSync();

    expect(zoom.contains('InteractiveViewer('), isTrue);
    expect(zoom.contains('maxScale: 8'), isTrue);
    expect(zoom.contains('Icons.zoom_in_rounded'), isTrue);
    expect(zoom.contains('Icons.zoom_out_rounded'), isTrue);
    expect(lesson.contains('VisualZoomScreen('), isTrue);
    expect(lesson.contains("'Tap to zoom'"), isTrue);
    expect(lesson.contains('aspectRatio: 4 / 5'), isTrue);
  });

  test('visual mockup opens guided full screen concept view', () {
    final concept =
        File('lib/screens/visual_concept_screen.dart').readAsStringSync();
    final lesson =
        File('lib/screens/lesson_screen.dart').readAsStringSync();

    expect(concept.contains('InteractiveViewer('), isTrue);
    expect(concept.contains("'কী দেখছ?'"), isTrue);
    expect(concept.contains("'কী বুঝবে?'"), isTrue);
    expect(concept.contains("'মনে রাখো'"), isTrue);
    expect(concept.contains("'What should you understand?'"), isTrue);
    expect(lesson.contains('VisualConceptScreen(card: card)'), isTrue);
  });
}
