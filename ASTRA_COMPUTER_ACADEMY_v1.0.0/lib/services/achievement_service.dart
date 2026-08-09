import 'mastery_service.dart';
import 'progress_repository.dart';

class SkillBadge {
  const SkillBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
}

class AchievementService {
  const AchievementService();

  List<SkillBadge> buildBadges({
    required List<CourseMastery> mastery,
    required Map<String, LessonProgress> progress,
    required LearningActivityStats activity,
  }) {
    final completedCount = progress.values.where((item) => item.completed).length;
    final scores = progress.values.map((item) => item.bestScore);
    final word = _find(mastery, 'ms_word');
    final excel = _find(mastery, 'ms_excel');
    final anyCourseFinished = mastery.any((item) => item.completionPercent == 100);
    final overall = mastery.isEmpty
        ? 0
        : (mastery.fold<int>(0, (sum, item) => sum + item.masteryScore) / mastery.length).round();

    return [
      SkillBadge(
        id: 'first_step',
        title: 'First Step',
        description: 'প্রথম lesson সম্পন্ন করুন',
        icon: '🚀',
        unlocked: completedCount >= 1,
      ),
      SkillBadge(
        id: 'streak_3',
        title: '3 Day Streak',
        description: 'টানা ৩ দিন শেখার activity রাখুন',
        icon: '🔥',
        unlocked: activity.currentStreak >= 3 || activity.longestStreak >= 3,
      ),
      SkillBadge(
        id: 'accuracy_95',
        title: 'Accuracy Hero',
        description: 'কোনও practical-এ 95% বা বেশি score করুন',
        icon: '🎯',
        unlocked: scores.any((score) => score >= 95),
      ),
      SkillBadge(
        id: 'word_pro',
        title: 'Word Pro',
        description: 'MS Word mastery 80+ করুন',
        icon: '📄',
        unlocked: (word?.masteryScore ?? 0) >= 80,
      ),
      SkillBadge(
        id: 'excel_pro',
        title: 'Excel Pro',
        description: 'MS Excel mastery 80+ করুন',
        icon: '📊',
        unlocked: (excel?.masteryScore ?? 0) >= 80,
      ),
      SkillBadge(
        id: 'course_finisher',
        title: 'Course Finisher',
        description: 'একটি course-এর সব lesson শেষ করুন',
        icon: '🏁',
        unlocked: anyCourseFinished,
      ),
      SkillBadge(
        id: 'office_ready',
        title: 'Office Ready',
        description: 'Overall mastery 80+ করুন',
        icon: '🏆',
        unlocked: overall >= 80,
      ),
    ];
  }

  CourseMastery? _find(List<CourseMastery> items, String id) {
    for (final item in items) {
      if (item.courseId == id) return item;
    }
    return null;
  }
}
