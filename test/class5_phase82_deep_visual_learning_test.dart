import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Phase 8.2 deep overrides cover every Class V lesson', () {
    final base = jsonDecode(
      File('assets/content/class5_cursor_pro.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final overridesRoot = jsonDecode(
      File('assets/content/class5_deep_visual_overrides.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;

    final lessonIds = <String>{};
    for (final courseRaw in base['courses'] as List<dynamic>) {
      final course = Map<String, dynamic>.from(courseRaw as Map);
      for (final lessonRaw in course['lessons'] as List<dynamic>) {
        final lesson = Map<String, dynamic>.from(lessonRaw as Map);
        lessonIds.add(lesson['id'] as String);
      }
    }

    final overrides = Map<String, dynamic>.from(
      overridesRoot['lessonOverrides'] as Map,
    );

    expect(lessonIds.length, 27);
    expect(overrides.keys.toSet(), lessonIds);

    for (final id in lessonIds) {
      final override = Map<String, dynamic>.from(overrides[id] as Map);
      expect(override['appendContentBn'] as List<dynamic>, isNotEmpty,
          reason: '$id Bengali deep content');
      expect(override['appendContentEn'] as List<dynamic>, isNotEmpty,
          reason: '$id English deep content');
      expect(override['appendLearningGoalsBn'] as List<dynamic>, isNotEmpty,
          reason: '$id learning goal');
      expect(override['appendExamplesBn'] as List<dynamic>, isNotEmpty,
          reason: '$id real-life example');
      expect(override['appendRecapBn'] as List<dynamic>, isNotEmpty,
          reason: '$id recap');
      expect(override['appendCommonMistakesBn'] as List<dynamic>, isNotEmpty,
          reason: '$id misconception');
      expect(override['appendImportantWords'] as List<dynamic>, isNotEmpty,
          reason: '$id vocabulary');
    }
  });

  test('computer generations uses visual-first child-friendly poster', () {
    final root = jsonDecode(
      File('assets/content/class5_deep_visual_overrides.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    final overrides = Map<String, dynamic>.from(
      root['lessonOverrides'] as Map,
    );
    final generations = Map<String, dynamic>.from(
      overrides['c5_01_01'] as Map,
    );

    const expectedAsset =
        'assets/visuals/class5/computer_generations_visual_first.jpg';
    expect(generations['visualAsset'], expectedAsset);

    final image = File(expectedAsset);
    expect(image.existsSync(), isTrue);
    expect(image.lengthSync(), greaterThan(100000));
    expect(
      (generations['visualCaptionBn'] as String).contains('১ম থেকে ৫ম'),
      isTrue,
    );
  });

  test('content repository applies additive overrides safely', () {
    final source =
        File('lib/services/content_repository.dart').readAsStringSync();

    expect(source.contains('class5_deep_visual_overrides.json'), isTrue);
    expect(source.contains("'appendContentBn': 'contentBn'"), isTrue);
    expect(source.contains("'appendImportantWords': 'importantWords'"), isTrue);
    expect(source.contains('merged.addAll(override)'), isTrue);
  });

  test('lesson screen presents the learning visual before long explanation', () {
    final source = File('lib/screens/lesson_screen.dart').readAsStringSync();
    final visualIndex = source.indexOf('if (lesson.hasVisualAsset)');
    final explanationIndex = source.indexOf("'সহজ ব্যাখ্যা'");

    expect(visualIndex, greaterThanOrEqualTo(0));
    expect(explanationIndex, greaterThanOrEqualTo(0));
    expect(visualIndex, lessThan(explanationIndex));
    expect(source.contains("'ছবি দেখে শুরু করি'"), isTrue);
  });
}
