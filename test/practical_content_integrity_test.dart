import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('interactive practicals contain required data', () {
    final raw = File('assets/content/curriculum.json').readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final courses = json['courses'] as List<dynamic>;

    var practicalCount = 0;
    for (final courseItem in courses) {
      final course = courseItem as Map<String, dynamic>;
      for (final lessonItem in course['lessons'] as List<dynamic>) {
        final lesson = lessonItem as Map<String, dynamic>;
        final kind = lesson['practicalKind'] as String?;
        if (kind == null) continue;
        practicalCount++;
        final data = Map<String, dynamic>.from(lesson['practicalData'] as Map);

        if (kind.startsWith('word_')) {
          expect(data['task'], isA<Map>());
          expect((data['task'] as Map).isNotEmpty, isTrue);
        } else if (kind.startsWith('excel_')) {
          expect(data['rows'], isA<int>());
          expect(data['columns'], isA<int>());
          final task = Map<String, dynamic>.from(data['task'] as Map);
          expect(task['expectedCells'], isA<List>());
          expect((task['expectedCells'] as List).isNotEmpty, isTrue);
        } else if (kind == 'typing') {
          expect((data['targetText'] as String).trim(), isNotEmpty);
          expect((data['targetWpm'] as num), greaterThan(0));
          expect((data['targetAccuracy'] as num), inInclusiveRange(1, 100));
        } else if (kind == 'data_entry') {
          expect(data['fields'], isA<List>());
          expect((data['fields'] as List).isNotEmpty, isTrue);
        } else if (kind == 'windows_file_manager') {
          expect(data['initialFiles'], isA<List>());
          expect(data['requirements'], isA<List>());
          expect((data['requirements'] as List).isNotEmpty, isTrue);
        } else if (kind == 'internet_browser') {
          expect(data['pages'], isA<List>());
          expect(data['requirements'], isA<List>());
          expect((data['pages'] as List).isNotEmpty, isTrue);
        } else if (kind == 'office_project') {
          expect(data['tasks'], isA<List>());
          expect((data['tasks'] as List).length, greaterThanOrEqualTo(3));
        }
      }
    }

    expect(practicalCount, greaterThanOrEqualTo(16));
  });
}
