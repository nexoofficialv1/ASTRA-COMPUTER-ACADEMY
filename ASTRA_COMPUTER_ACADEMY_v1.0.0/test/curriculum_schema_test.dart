import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('curriculum has unique course and lesson ids', () {
    final raw = File('assets/content/curriculum.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = json['courses'] as List<dynamic>;

    final courseIds = <String>{};
    final lessonIds = <String>{};

    for (final item in courses) {
      final course = item as Map<String, dynamic>;
      expect(courseIds.add(course['id'] as String), isTrue);

      for (final lessonItem in course['lessons'] as List<dynamic>) {
        final lesson = lessonItem as Map<String, dynamic>;
        expect(lessonIds.add(lesson['id'] as String), isTrue);
      }
    }
  });
}
