import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Class V Windows Word and Internet practicals are mapped', () {
    final raw =
        File('assets/content/class5_cursor_pro.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = json['courses'] as List<dynamic>;
    final lessons = <String, Map<String, dynamic>>{};

    for (final courseItem in courses) {
      final course = courseItem as Map<String, dynamic>;
      for (final lessonItem in course['lessons'] as List<dynamic>) {
        final lesson = lessonItem as Map<String, dynamic>;
        lessons[lesson['id'] as String] = lesson;
      }
    }

    expect(lessons['c5_03_02']!['practicalKind'], 'windows_file_manager');
    expect(
      lessons['c5_03_03']!['practicalKind'],
      'windows_personalization',
    );
    expect(lessons['c5_04_01']!['practicalKind'], 'word_advanced');
    expect(lessons['c5_04_02']!['practicalKind'], 'word_advanced');
    expect(lessons['c5_04_03']!['practicalKind'], 'word_advanced');
    expect(lessons['c5_06_03']!['practicalKind'], 'internet_browser');

    for (final id in [
      'c5_03_02',
      'c5_03_03',
      'c5_04_01',
      'c5_04_02',
      'c5_04_03',
      'c5_06_03',
    ]) {
      expect(
        Map<String, dynamic>.from(
          lessons[id]!['practicalData'] as Map,
        ),
        isNotEmpty,
      );
    }
  });

  test('new Class V advanced lab screens are routed', () {
    expect(
      File('lib/screens/windows_personalization_lab_screen.dart')
          .existsSync(),
      isTrue,
    );
    expect(
      File('lib/screens/word_advanced_lab_screen.dart').existsSync(),
      isTrue,
    );

    final lessonScreen =
        File('lib/screens/lesson_screen.dart').readAsStringSync();
    expect(
      lessonScreen.contains(
        "lesson.practicalKind == 'windows_personalization'",
      ),
      isTrue,
    );
    expect(
      lessonScreen.contains("lesson.practicalKind == 'word_advanced'"),
      isTrue,
    );
  });
}
