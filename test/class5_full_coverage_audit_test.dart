import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Class V coverage manifest proves every required topic mapping', () {
    final curriculum = jsonDecode(
      File('assets/content/class5_cursor_pro.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final manifest = jsonDecode(
      File('assets/content/class5_coverage_manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final orderedCourses = (curriculum['courses'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    final courses = <String, Map<String, dynamic>>{
      for (final course in orderedCourses) course['id'] as String: course,
    };

    final lessons = <String, Map<String, dynamic>>{};
    for (final course in orderedCourses) {
      for (final lessonItem in course['lessons'] as List<dynamic>) {
        final lesson = Map<String, dynamic>.from(lessonItem as Map);
        lessons[lesson['id'] as String] = lesson;
      }
    }

    expect(orderedCourses.length, 9);
    expect(lessons.length, 27);

    final chapters = (manifest['chapters'] as List<dynamic>)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    expect(chapters.length, 9);

    final seenTopicIds = <String>{};
    var topicCount = 0;

    for (var chapterIndex = 0;
        chapterIndex < chapters.length;
        chapterIndex++) {
      final chapter = chapters[chapterIndex];
      final course = orderedCourses[chapterIndex];

      expect(chapter['status'], 'complete');
      expect(
        chapter['courseId'],
        course['id'],
        reason: 'chapter ${chapterIndex + 1} must map to authoritative course',
      );
      expect(
        courses.containsKey(chapter['courseId']),
        isTrue,
      );

      for (final topicItem in chapter['topics'] as List<dynamic>) {
        final topic = Map<String, dynamic>.from(topicItem as Map);
        final topicId = topic['id'] as String;

        expect(
          seenTopicIds.add(topicId),
          isTrue,
          reason: 'duplicate topic $topicId',
        );
        topicCount++;

        final lessonId = topic['lessonId'] as String;
        expect(
          lessons.containsKey(lessonId),
          isTrue,
          reason: '$topicId -> missing $lessonId',
        );

        final lesson = lessons[lessonId]!;
        final tags = List<String>.from(
          lesson['coverageTags'] as List<dynamic>? ?? const [],
        );

        expect(
          tags,
          contains('topic:$topicId'),
          reason: '$topicId must have explicit lesson coverage tag',
        );

        final keywords = List<String>.from(
          topic['keywords'] as List<dynamic>? ?? const [],
        );
        expect(
          keywords,
          isNotEmpty,
          reason: '$topicId must retain human-readable evidence hints',
        );

        final requiredKind = topic['practicalKind'] as String?;
        if (requiredKind != null) {
          expect(
            lesson['practicalKind'],
            requiredKind,
            reason: '$topicId practical mapping',
          );
          expect(
            Map<String, dynamic>.from(
              lesson['practicalData'] as Map? ?? const {},
            ),
            isNotEmpty,
          );
        }
      }
    }

    expect(topicCount, greaterThanOrEqualTo(80));
    expect(manifest['verifiedTopicCount'], topicCount);
    expect(manifest['verifiedChapterCount'], 9);

    for (final itemRaw in manifest['crossCutting'] as List<dynamic>) {
      final item = Map<String, dynamic>.from(itemRaw as Map);
      final lessonId = item['lessonId'] as String;
      expect(lessons.containsKey(lessonId), isTrue);

      final tags = List<String>.from(
        lessons[lessonId]!['coverageTags'] as List<dynamic>? ?? const [],
      );
      expect(
        tags,
        contains('cross:${item['id']}'),
        reason: 'cross-cutting ${item['id']} must be explicitly mapped',
      );
    }
  });

  test('previously non-interactive Class V practical gaps are closed', () {
    final curriculum = jsonDecode(
      File('assets/content/class5_cursor_pro.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    final lessons = <String, Map<String, dynamic>>{};
    for (final courseItem in curriculum['courses'] as List<dynamic>) {
      final course = Map<String, dynamic>.from(courseItem as Map);
      for (final lessonItem in course['lessons'] as List<dynamic>) {
        final lesson = Map<String, dynamic>.from(lessonItem as Map);
        lessons[lesson['id'] as String] = lesson;
      }
    }

    expect(lessons['c5_01_03']!['practicalKind'], 'concept_sort');
    expect(lessons['c5_02_03']!['practicalKind'], 'concept_sort');
    expect(lessons['c5_07_03']!['practicalKind'], 'scratch');
    expect(lessons['c5_08_01']!['practicalKind'], 'scratch');

    final paint = Map<String, dynamic>.from(
      lessons['c5_05_03']!['practicalData'] as Map,
    );
    expect(paint['requireSave'], isTrue);
    expect(paint['requireOpen'], isTrue);

    final scratchWorkflow = Map<String, dynamic>.from(
      lessons['c5_07_03']!['practicalData'] as Map,
    );
    expect(
      List<String>.from(
        scratchWorkflow['requiredActions'] as List<dynamic>,
      ),
      containsAll([
        'duplicate_sprite',
        'save_project',
        'open_project',
        'exit_project',
      ]),
    );

    final scratchScene = Map<String, dynamic>.from(
      lessons['c5_08_01']!['practicalData'] as Map,
    );
    expect(
      List<String>.from(
        scratchScene['requiredActions'] as List<dynamic>,
      ),
      containsAll([
        'select_sprite',
        'choose_costume',
        'choose_backdrop',
      ]),
    );
  });
}
