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

  bool get isPractical => type == 'practical';
  bool get hasInteractivePractical => practicalKind != null;

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
    );
  }
}
