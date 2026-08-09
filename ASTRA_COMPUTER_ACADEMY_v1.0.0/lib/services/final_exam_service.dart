import '../models/course.dart';
import '../models/lesson.dart';
import 'progress_repository.dart';

class FinalExamComponent {
  const FinalExamComponent({
    required this.lessonId,
    required this.label,
    required this.minimumScore,
  });

  final String lessonId;
  final String label;
  final int minimumScore;
}

class FinalExamResult {
  const FinalExamResult({
    required this.score,
    required this.passed,
    required this.componentScores,
    required this.allComponentsAttempted,
  });

  final int score;
  final bool passed;
  final Map<String, int> componentScores;
  final bool allComponentsAttempted;
}

class FinalExamService {
  const FinalExamService();

  static const components = <FinalExamComponent>[
    FinalExamComponent(
      lessonId: 'word_007',
      label: 'Word: Resume Practical',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'word_011',
      label: 'Word: Header/Footer/Page Number',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'excel_005',
      label: 'Excel: Mark Sheet',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'excel_014',
      label: 'Excel: Sort & Filter',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'typing_002',
      label: 'Typing: English Office Typing',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'de_005',
      label: 'Data Entry: Office Master Record',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'windows_008',
      label: 'Windows: Desktop & Taskbar',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'internet_006',
      label: 'Email: Compose & Attachment',
      minimumScore: 60,
    ),
    FinalExamComponent(
      lessonId: 'ppt_003',
      label: 'PowerPoint: Office Presentation',
      minimumScore: 60,
    ),
  ];


  FinalExamResult evaluate(Map<String, LessonProgress> progress) {
    final scores = <String, int>{
      for (final item in components)
        item.lessonId: progress[item.lessonId]?.bestScore ?? 0,
    };
    final attempted = scores.values.every((score) => score > 0);
    final minimumsMet = components.every(
      (item) => (scores[item.lessonId] ?? 0) >= item.minimumScore,
    );
    final average = scores.isEmpty
        ? 0
        : (scores.values.fold<int>(0, (sum, score) => sum + score) /
                scores.length)
            .round();
    return FinalExamResult(
      score: average,
      passed: attempted && minimumsMet && average >= 70,
      componentScores: scores,
      allComponentsAttempted: attempted,
    );
  }

  Lesson? findLesson(List<Course> courses, String lessonId) {
    for (final course in courses) {
      for (final lesson in course.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
