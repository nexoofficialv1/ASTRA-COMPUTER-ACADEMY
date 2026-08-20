import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Class V new interactive labs are wired in curriculum', () {
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

    expect(lessons['c5_05_02']!['practicalKind'], 'paint3d');
    expect(lessons['c5_05_03']!['practicalKind'], 'paint3d');
    expect(lessons['c5_07_02']!['practicalKind'], 'scratch');
    expect(lessons['c5_08_02']!['practicalKind'], 'scratch');
    expect(lessons['c5_08_03']!['practicalKind'], 'scratch');
    expect(lessons['c5_09_03']!['practicalKind'], 'ai_decision');

    for (final id in [
      'c5_05_02',
      'c5_05_03',
      'c5_07_02',
      'c5_08_02',
      'c5_08_03',
      'c5_09_03',
    ]) {
      expect(
        lessons[id]!['practicalData'] as Map<String, dynamic>,
        isNotEmpty,
      );
    }
  });

  test('interactive lab screens and routing exist', () {
    expect(
      File('lib/screens/paint3d_lab_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      File('lib/screens/scratch_lab_screen.dart').existsSync(),
      isTrue,
    );
    expect(
      File('lib/screens/ai_decision_lab_screen.dart').existsSync(),
      isTrue,
    );

    final lessonScreen =
        File('lib/screens/lesson_screen.dart').readAsStringSync();
    expect(
      lessonScreen.contains("lesson.practicalKind == 'paint3d'"),
      isTrue,
    );
    expect(
      lessonScreen.contains("lesson.practicalKind == 'scratch'"),
      isTrue,
    );
    expect(
      lessonScreen.contains("lesson.practicalKind == 'ai_decision'"),
      isTrue,
    );
  });
}
