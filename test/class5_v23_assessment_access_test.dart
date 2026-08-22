import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Class V v23 has at least four quiz questions per lesson', () {
    final base = jsonDecode(
      File('assets/content/class5_cursor_pro.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final overrides = jsonDecode(
      File('assets/content/class5_deep_visual_overrides.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final byId = Map<String, dynamic>.from(
      overrides['lessonOverrides'] as Map,
    );

    var lessonCount = 0;
    for (final courseRaw in base['courses'] as List<dynamic>) {
      final course = Map<String, dynamic>.from(courseRaw as Map);
      var chapterQuestions = 0;
      for (final lessonRaw in course['lessons'] as List<dynamic>) {
        final lesson = Map<String, dynamic>.from(lessonRaw as Map);
        final id = lesson['id'] as String;
        final baseQuiz = List<dynamic>.from(lesson['quiz'] as List<dynamic>? ?? const []);
        final override = Map<String, dynamic>.from(byId[id] as Map);
        final added = List<dynamic>.from(
          override['appendQuiz'] as List<dynamic>? ?? const [],
        );
        expect(baseQuiz.length + added.length, greaterThanOrEqualTo(4), reason: id);
        chapterQuestions += baseQuiz.length + added.length;
        lessonCount++;
      }
      expect(chapterQuestions, greaterThanOrEqualTo(12), reason: course['id'] as String);
    }
    expect(lessonCount, 27);
  });

  test('school practical lessons remain visible in Learn/Lessons tab', () {
    final source = File('lib/screens/course_detail_screen.dart').readAsStringSync();
    expect(source.contains('widget.course.isSchoolCourse'), isTrue);
    expect(source.contains('? widget.course.lessons'), isTrue);
    expect(source.contains('item.hasInteractivePractical'), isTrue);
  });

  test('MS Excel is surfaced as a Class V bonus skill without changing the 9 syllabus chapters', () {
    final source = File('lib/screens/course_library_screen.dart').readAsStringSync();
    expect(source.contains("course.id == 'ms_excel'"), isTrue);
    expect(source.contains("'Class V Bonus Skill'"), isTrue);
    expect(source.contains("'MS Excel'"), isTrue);

    final core = jsonDecode(
      File('assets/content/curriculum.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final courses = (core['courses'] as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final excel = courses.firstWhere((c) => c['id'] == 'ms_excel');
    expect((excel['lessons'] as List<dynamic>).length, greaterThanOrEqualTo(3));
  });

  test('question expansion is bilingual and valid', () {
    final root = jsonDecode(
      File('assets/content/class5_deep_visual_overrides.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final overrides = Map<String, dynamic>.from(root['lessonOverrides'] as Map);

    for (final entry in overrides.entries) {
      final lesson = Map<String, dynamic>.from(entry.value as Map);
      final added = List<dynamic>.from(lesson['appendQuiz'] as List<dynamic>? ?? const []);
      expect(added.length, greaterThanOrEqualTo(3), reason: entry.key);
      for (final raw in added) {
        final q = Map<String, dynamic>.from(raw as Map);
        expect((q['question'] as String).trim(), isNotEmpty);
        expect((q['questionEn'] as String).trim(), isNotEmpty);
        expect((q['options'] as List<dynamic>).length, 4);
        expect((q['optionsEn'] as List<dynamic>).length, 4);
        expect(q['correctIndex'] as int, inInclusiveRange(0, 3));
      }
    }
  });
}
