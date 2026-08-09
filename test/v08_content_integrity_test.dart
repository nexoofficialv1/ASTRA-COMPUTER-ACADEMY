import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('v0.8 curriculum contains release-candidate practical coverage', () async {
    final raw = await rootBundle.loadString('assets/content/curriculum.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final courses = data['courses'] as List<dynamic>;
    final lessons = courses
        .expand((course) => (course as Map<String, dynamic>)['lessons'] as List<dynamic>)
        .map((lesson) => lesson as Map<String, dynamic>)
        .toList();

    expect(lessons.length, 60);
    expect(lessons.where((lesson) => lesson['practicalKind'] != null).length, 40);

    final ids = lessons.map((lesson) => lesson['id']).toSet();
    expect(
      ids,
      containsAll([
        'word_011',
        'excel_013',
        'excel_014',
        'excel_015',
        'excel_016',
        'windows_008',
        'internet_006',
        'internet_007',
      ]),
    );

    final kinds = lessons.map((lesson) => lesson['practicalKind']).whereType<String>().toSet();
    expect(kinds, containsAll(['word_page_elements', 'excel_workflow', 'windows_desktop', 'email_compose']));
  });
}
