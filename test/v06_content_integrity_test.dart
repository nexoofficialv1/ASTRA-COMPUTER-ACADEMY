import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v0.6 curriculum includes Windows, Internet and Office Project', () {
    final raw = File('assets/content/curriculum.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = (json['courses'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    final ids = courses.map((course) => course['id']).toSet();
    expect(ids, contains('windows_basics'));
    expect(ids, contains('internet_basics'));
    expect(ids, contains('office_projects'));

    final lessons = courses
        .expand((course) => course['lessons'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();
    expect(lessons.length, greaterThanOrEqualTo(36));
    expect(
      lessons.where((lesson) => lesson['practicalKind'] != null).length,
      greaterThanOrEqualTo(26),
    );
  });
}
