import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class ContentRepository {
  List<Course>? _coreCache;
  List<Course>? _schoolCache;
  List<Course>? _allCache;

  Future<List<Course>> loadCourses() async {
    if (_coreCache != null) return _coreCache!;

    _coreCache = await _loadAsset('assets/content/curriculum.json');
    return _coreCache!;
  }

  Future<List<Course>> loadSchoolCourses() async {
    if (_schoolCache != null) return _schoolCache!;

    _schoolCache = await _loadSchoolAssetWithOverrides(
      'assets/content/class5_cursor_pro.json',
      'assets/content/class5_deep_visual_overrides.json',
    );
    return _schoolCache!;
  }

  Future<List<Course>> loadAllCourses() async {
    if (_allCache != null) return _allCache!;

    final results = await Future.wait([
      loadCourses(),
      loadSchoolCourses(),
    ]);
    _allCache = <Course>[
      ...results[0],
      ...results[1],
    ];
    return _allCache!;
  }

  Future<List<Course>> _loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['courses'] as List<dynamic>)
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Course>> _loadSchoolAssetWithOverrides(
    String baseAssetPath,
    String overrideAssetPath,
  ) async {
    final results = await Future.wait([
      rootBundle.loadString(baseAssetPath),
      rootBundle.loadString(overrideAssetPath),
    ]);

    final decoded = jsonDecode(results[0]) as Map<String, dynamic>;
    final overrideRoot = jsonDecode(results[1]) as Map<String, dynamic>;
    final lessonOverrides = Map<String, dynamic>.from(
      overrideRoot['lessonOverrides'] as Map? ?? const {},
    );

    return (decoded['courses'] as List<dynamic>).map((courseRaw) {
      final course = Map<String, dynamic>.from(courseRaw as Map);
      course['lessons'] = (course['lessons'] as List<dynamic>).map((lessonRaw) {
        final lesson = Map<String, dynamic>.from(lessonRaw as Map);
        final lessonId = lesson['id'] as String;
        final overrideRaw = lessonOverrides[lessonId];
        if (overrideRaw is Map) {
          return _applyLessonOverride(
            lesson,
            Map<String, dynamic>.from(overrideRaw),
          );
        }
        return lesson;
      }).toList();
      return Course.fromJson(course);
    }).toList();
  }

  Map<String, dynamic> _applyLessonOverride(
    Map<String, dynamic> lesson,
    Map<String, dynamic> override,
  ) {
    final merged = Map<String, dynamic>.from(lesson);

    const appendFields = <String, String>{
      'appendContentBn': 'contentBn',
      'appendContentEn': 'contentEn',
      'appendLearningGoalsBn': 'learningGoalsBn',
      'appendLearningGoalsEn': 'learningGoalsEn',
      'appendExamplesBn': 'examplesBn',
      'appendExamplesEn': 'examplesEn',
      'appendRecapBn': 'recapBn',
      'appendRecapEn': 'recapEn',
      'appendCommonMistakesBn': 'commonMistakesBn',
      'appendCommonMistakesEn': 'commonMistakesEn',
      'appendImportantWords': 'importantWords',
      'appendMockupCards': 'mockupCards',
      'appendQuiz': 'quiz',
    };

    for (final mapping in appendFields.entries) {
      final additions = override.remove(mapping.key);
      if (additions is! List || additions.isEmpty) continue;

      final existing = List<dynamic>.from(
        merged[mapping.value] as List<dynamic>? ?? const [],
      );
      merged[mapping.value] = <dynamic>[
        ...existing,
        ...additions,
      ];
    }

    // Remaining values are direct replacements, used for visual assets/captions
    // or any intentionally overridden scalar field.
    merged.addAll(override);
    return merged;
  }
}
