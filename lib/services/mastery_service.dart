import '../models/course.dart';
import 'progress_repository.dart';

class CourseMastery {
  const CourseMastery({
    required this.courseId,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.completionPercent,
    required this.practicalAverage,
    required this.masteryScore,
    required this.levelLabel,
  });

  final String courseId;
  final String title;
  final int completedLessons;
  final int totalLessons;
  final int completionPercent;
  final int practicalAverage;
  final int masteryScore;
  final String levelLabel;
}

class MasteryService {
  const MasteryService();

  List<CourseMastery> calculateCourses({
    required List<Course> courses,
    required Map<String, LessonProgress> progress,
  }) {
    return courses.map((course) {
      final total = course.lessons.length;
      final completed = course.lessons
          .where((lesson) => progress[lesson.id]?.completed == true)
          .length;
      final completion = total == 0 ? 0 : ((completed / total) * 100).round();
      final practicals = course.lessons.where((lesson) => lesson.hasInteractivePractical).toList();
      final practicalAverage = practicals.isEmpty
          ? completion
          : (practicals.fold<int>(
                    0,
                    (sum, lesson) => sum + (progress[lesson.id]?.bestScore ?? 0),
                  ) /
                  practicals.length)
              .round();
      final mastery = practicals.isEmpty
          ? completion
          : (completion * 0.40 + practicalAverage * 0.60).round();

      return CourseMastery(
        courseId: course.id,
        title: course.titleBn,
        completedLessons: completed,
        totalLessons: total,
        completionPercent: completion,
        practicalAverage: practicalAverage,
        masteryScore: mastery.clamp(0, 100).toInt(),
        levelLabel: _label(mastery),
      );
    }).toList();
  }

  int overallMastery(List<CourseMastery> courses) {
    if (courses.isEmpty) return 0;
    return (courses.fold<int>(0, (sum, item) => sum + item.masteryScore) /
            courses.length)
        .round();
  }

  String _label(int score) {
    if (score >= 90) return 'Mastered';
    if (score >= 75) return 'Proficient';
    if (score >= 50) return 'Developing';
    if (score > 0) return 'Beginner';
    return 'Not Started';
  }
}
