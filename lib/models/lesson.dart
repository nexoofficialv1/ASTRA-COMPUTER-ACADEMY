import 'quiz_question.dart';

class Lesson {
  const Lesson({
    required this.id,
    required this.titleBn,
    required this.summaryBn,
    required this.durationMinutes,
    required this.type,
    required this.contentBn,
    required this.steps,
    required this.quiz,
    required this.practicalKind,
    required this.practicalData,
    this.titleEn = '',
    this.summaryEn = '',
    this.contentEn = const [],
    this.stepsEn = const [],
    this.learningGoalsBn = const [],
    this.learningGoalsEn = const [],
    this.examplesBn = const [],
    this.examplesEn = const [],
    this.recapBn = const [],
    this.recapEn = const [],
    this.commonMistakesBn = const [],
    this.commonMistakesEn = const [],
    this.importantWords = const [],
    this.mockupCards = const [],
  });

  final String id;
  final String titleBn;
  final String summaryBn;
  final int durationMinutes;
  final String type;
  final List<String> contentBn;
  final List<String> steps;
  final List<QuizQuestion> quiz;
  final String? practicalKind;
  final Map<String, dynamic> practicalData;

  final String titleEn;
  final String summaryEn;
  final List<String> contentEn;
  final List<String> stepsEn;
  final List<String> learningGoalsBn;
  final List<String> learningGoalsEn;
  final List<String> examplesBn;
  final List<String> examplesEn;
  final List<String> recapBn;
  final List<String> recapEn;
  final List<String> commonMistakesBn;
  final List<String> commonMistakesEn;
  final List<Map<String, dynamic>> importantWords;
  final List<Map<String, dynamic>> mockupCards;

  bool get isPractical => type == 'practical';
  bool get hasInteractivePractical => practicalKind != null;
  bool get hasEnglishExplanation =>
      summaryEn.trim().isNotEmpty || contentEn.isNotEmpty || stepsEn.isNotEmpty;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      titleBn: json['titleBn'] as String,
      summaryBn: json['summaryBn'] as String,
      durationMinutes: json['durationMinutes'] as int,
      type: json['type'] as String,
      contentBn: List<String>.from(json['contentBn'] as List<dynamic>? ?? const []),
      steps: List<String>.from(json['steps'] as List<dynamic>? ?? const []),
      quiz: (json['quiz'] as List<dynamic>? ?? const [])
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
      practicalKind: json['practicalKind'] as String?,
      practicalData: Map<String, dynamic>.from(
        json['practicalData'] as Map<String, dynamic>? ?? const {},
      ),
      titleEn: json['titleEn'] as String? ?? '',
      summaryEn: json['summaryEn'] as String? ?? '',
      contentEn: List<String>.from(json['contentEn'] as List<dynamic>? ?? const []),
      stepsEn: List<String>.from(json['stepsEn'] as List<dynamic>? ?? const []),
      learningGoalsBn: List<String>.from(json['learningGoalsBn'] as List<dynamic>? ?? const []),
      learningGoalsEn: List<String>.from(json['learningGoalsEn'] as List<dynamic>? ?? const []),
      examplesBn: List<String>.from(json['examplesBn'] as List<dynamic>? ?? const []),
      examplesEn: List<String>.from(json['examplesEn'] as List<dynamic>? ?? const []),
      recapBn: List<String>.from(json['recapBn'] as List<dynamic>? ?? const []),
      recapEn: List<String>.from(json['recapEn'] as List<dynamic>? ?? const []),
      commonMistakesBn: List<String>.from(json['commonMistakesBn'] as List<dynamic>? ?? const []),
      commonMistakesEn: List<String>.from(json['commonMistakesEn'] as List<dynamic>? ?? const []),
      importantWords: (json['importantWords'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      mockupCards: (json['mockupCards'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
    );
  }
}
