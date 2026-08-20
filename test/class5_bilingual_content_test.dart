import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all Class V lessons and quizzes are bilingual', () {
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
      expect((lesson['titleEn'] as String).trim(), isNotEmpty, reason: id);
      expect((lesson['summaryEn'] as String).trim(), isNotEmpty, reason: id);
      expect((lesson['contentEn'] as List).isNotEmpty, isTrue, reason: id);
      expect((lesson['stepsEn'] as List).isNotEmpty, isTrue, reason: id);

      for (final quizRaw in lesson['quiz'] as List<dynamic>) {
        final quiz = Map<String, dynamic>.from(quizRaw as Map);
        expect((quiz['questionEn'] as String).trim(), isNotEmpty, reason: id);
        expect((quiz['explanationEn'] as String).trim(), isNotEmpty, reason: id);
        expect(
          (quiz['optionsEn'] as List).length,
          (quiz['options'] as List).length,
          reason: id,
        );
      }
    }
  });

  test('English fields are optional for legacy Foundation lessons', () {
    final lesson = File('lib/models/lesson.dart').readAsStringSync();
    final quiz = File('lib/models/quiz_question.dart').readAsStringSync();
    expect(lesson.contains("this.titleEn = ''"), isTrue);
    expect(lesson.contains('this.contentEn = const []'), isTrue);
    expect(quiz.contains("this.questionEn = ''"), isTrue);
    expect(quiz.contains('this.optionsEn = const []'), isTrue);
  });
}
