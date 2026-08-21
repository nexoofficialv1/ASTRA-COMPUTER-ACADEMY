import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all 27 Class V lessons have deep child-friendly sections', () {
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
      expect((lesson['titleEn'] as String?)?.trim(), isNotEmpty, reason: '$id titleEn');
      expect((lesson['summaryEn'] as String?)?.trim(), isNotEmpty, reason: '$id summaryEn');
      expect((lesson['contentEn'] as List?)?.isNotEmpty, isTrue, reason: '$id contentEn');
      expect((lesson['learningGoalsBn'] as List?)?.isNotEmpty, isTrue, reason: '$id learningGoalsBn');
      expect((lesson['learningGoalsEn'] as List?)?.isNotEmpty, isTrue, reason: '$id learningGoalsEn');
      expect((lesson['examplesBn'] as List?)?.isNotEmpty, isTrue, reason: '$id examplesBn');
      expect((lesson['examplesEn'] as List?)?.isNotEmpty, isTrue, reason: '$id examplesEn');
      expect((lesson['recapBn'] as List?)?.isNotEmpty, isTrue, reason: '$id recapBn');
      expect((lesson['recapEn'] as List?)?.isNotEmpty, isTrue, reason: '$id recapEn');
      expect((lesson['commonMistakesBn'] as List?)?.isNotEmpty, isTrue, reason: '$id mistakesBn');
      expect((lesson['commonMistakesEn'] as List?)?.isNotEmpty, isTrue, reason: '$id mistakesEn');
      expect((lesson['importantWords'] as List?)?.isNotEmpty, isTrue, reason: '$id importantWords');
      expect((lesson['mockupCards'] as List?)?.isNotEmpty, isTrue, reason: '$id mockupCards');

      for (final quizRaw in lesson['quiz'] as List<dynamic>) {
        final quiz = Map<String, dynamic>.from(quizRaw as Map);
        expect((quiz['questionEn'] as String?)?.trim(), isNotEmpty, reason: '$id quiz questionEn');
        expect((quiz['explanationEn'] as String?)?.trim(), isNotEmpty, reason: '$id quiz explanationEn');
        expect((quiz['optionsEn'] as List?)?.length, (quiz['options'] as List).length,
            reason: '$id quiz optionsEn');
      }
    }
  });

  test('lesson screen contains sections needed for easy learning', () {
    final content = File('lib/screens/lesson_screen.dart').readAsStringSync();
    expect(content.contains('এই lesson-এ কী শিখবে'), isTrue);
    expect(content.contains('সহজ ব্যাখ্যা'), isTrue);
    expect(content.contains('উদাহরণ'), isTrue);
    expect(content.contains('ভিজ্যুয়াল mockup'), isTrue);
    expect(content.contains('গুরুত্বপূর্ণ শব্দ'), isTrue);
    expect(content.contains('Quick Recap'), isTrue);
    expect(content.contains('Common Mistakes'), isTrue);
    expect(content.contains('English Explanation'), isTrue);
  });
}
