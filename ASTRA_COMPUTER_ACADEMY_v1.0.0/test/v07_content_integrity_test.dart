import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('v0.7 curriculum includes PowerPoint and advanced office practicals', () async {
    final raw = await rootBundle.loadString('assets/content/curriculum.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final courses = data['courses'] as List<dynamic>;
    final ids = courses.map((c) => (c as Map<String, dynamic>)['id']).toSet();
    expect(ids, contains('ms_powerpoint'));

    final lessons = courses
        .expand((c) => (c as Map<String, dynamic>)['lessons'] as List<dynamic>)
        .map((l) => l as Map<String, dynamic>)
        .toList();
    final lessonIds = lessons.map((l) => l['id']).toSet();
    for (final id in ['word_009', 'excel_010', 'excel_011', 'excel_012', 'windows_006', 'ppt_002']) {
      expect(lessonIds, contains(id));
    }
  });
}
