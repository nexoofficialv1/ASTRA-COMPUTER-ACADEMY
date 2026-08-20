import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Class V school curriculum contains nine unique chapters', () {
    final raw =
        File('assets/content/class5_cursor_pro.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = json['courses'] as List<dynamic>;

    expect(json['track'], 'school');
    expect(json['grade'], 5);
    expect(courses.length, 9);

    final courseIds = <String>{};
    final lessonIds = <String>{};

    for (final item in courses) {
      final course = item as Map<String, dynamic>;
      expect(course['track'], 'school');
      expect(course['grade'], 5);
      expect(course['level'], 'Class V');
      expect(courseIds.add(course['id'] as String), isTrue);

      final lessons = course['lessons'] as List<dynamic>;
      expect(lessons, isNotEmpty);

      for (final lessonItem in lessons) {
        final lesson = lessonItem as Map<String, dynamic>;
        expect(lessonIds.add(lesson['id'] as String), isTrue);
        expect((lesson['contentBn'] as List<dynamic>), isNotEmpty);
        expect((lesson['quiz'] as List<dynamic>), isNotEmpty);
      }
    }
  });

  test('Class V chapter order matches the syllabus structure', () {
    final raw =
        File('assets/content/class5_cursor_pro.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = (json['courses'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(
      courses.map((course) => course['title'] as String).toList(),
      [
        'How Computer Works?',
        'Hardware & Software',
        'Getting Around in Windows 10',
        'Advanced Features of Word 2019',
        'Enjoying with Paint 3D',
        'Introduction to Internet',
        'Introduction to Scratch 3',
        'Simple Programming in Scratch',
        'Human vs Artificial Intelligence',
      ],
    );
  });
}
