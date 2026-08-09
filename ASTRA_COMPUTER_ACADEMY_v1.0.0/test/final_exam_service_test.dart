import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/services/final_exam_service.dart';
import 'package:astra_computer_academy/services/progress_repository.dart';

void main() {
  test('final exam passes only when every core component is >= 60 and average >= 70', () {
    final progress = <String, LessonProgress>{
      for (final component in FinalExamService.components)
        component.lessonId: const LessonProgress(completed: true, bestScore: 75),
    };

    final result = const FinalExamService().evaluate(progress);
    expect(result.passed, isTrue);
    expect(result.score, 75);
    expect(result.componentScores.length, FinalExamService.components.length);
  });

  test('final exam fails if one component is below minimum', () {
    final progress = <String, LessonProgress>{
      for (final component in FinalExamService.components)
        component.lessonId: const LessonProgress(completed: true, bestScore: 90),
    };
    progress['internet_006'] = const LessonProgress(completed: true, bestScore: 55);

    final result = const FinalExamService().evaluate(progress);
    expect(result.passed, isFalse);
  });

  test('v0.8 final exam contains nine job-skill components', () {
    expect(FinalExamService.components.length, 9);
    final ids = FinalExamService.components.map((item) => item.lessonId).toSet();
    expect(ids, containsAll(['word_011', 'excel_014', 'windows_008', 'internet_006', 'ppt_003']));
  });
}
