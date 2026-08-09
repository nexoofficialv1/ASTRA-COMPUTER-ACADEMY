import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/models/course.dart';
import 'package:astra_computer_academy/models/lesson.dart';
import 'package:astra_computer_academy/services/mastery_service.dart';
import 'package:astra_computer_academy/services/progress_repository.dart';

void main() {
  test('mastery combines completion and practical score', () {
    const course = Course(
      id: 'demo',
      title: 'Demo',
      titleBn: 'Demo',
      subtitleBn: '',
      icon: 'D',
      level: 'Foundation',
      lessons: [
        Lesson(
          id: 'theory',
          titleBn: 'Theory',
          summaryBn: '',
          durationMinutes: 1,
          type: 'theory',
          contentBn: [],
          steps: [],
          quiz: [],
          practicalKind: null,
          practicalData: {},
        ),
        Lesson(
          id: 'practice',
          titleBn: 'Practice',
          summaryBn: '',
          durationMinutes: 1,
          type: 'practical',
          contentBn: [],
          steps: [],
          quiz: [],
          practicalKind: 'typing',
          practicalData: {},
        ),
      ],
    );

    final result = const MasteryService().calculateCourses(
      courses: [course],
      progress: {
        'theory': const LessonProgress(completed: true, bestScore: 0),
        'practice': const LessonProgress(completed: true, bestScore: 80),
      },
    ).single;

    expect(result.completionPercent, 100);
    expect(result.practicalAverage, 80);
    expect(result.masteryScore, 88);
  });
}
