import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/achievement_service.dart';
import '../services/certification_repository.dart';
import '../services/content_repository.dart';
import '../services/learner_profile_repository.dart';
import '../services/mastery_service.dart';
import '../services/progress_repository.dart';
import 'certificate_screen.dart';
import 'final_exam_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
    required this.profileRepository,
    required this.certificationRepository,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final LearnerProfileRepository profileRepository;
  final CertificationRepository certificationRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('আমার Progress')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          contentRepository.loadCourses(),
          progressRepository.getAllProgress(),
          progressRepository.getActivityStats(),
          certificationRepository.getBestFinalExamScore(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data![0] as List<Course>;
          final progress = snapshot.data![1] as Map<String, LessonProgress>;
          final activity = snapshot.data![2] as LearningActivityStats;
          final finalExamScore = snapshot.data![3] as int;
          final lessons = courses.expand((c) => c.lessons).toList();
          final completed = lessons
              .where((l) => progress[l.id]?.completed == true)
              .length;
          final scores = progress.values
              .where((p) => p.bestScore > 0)
              .map((p) => p.bestScore)
              .toList();
          final average = scores.isEmpty
              ? 0
              : (scores.reduce((a, b) => a + b) / scores.length).round();

          const masteryService = MasteryService();
          final mastery = masteryService.calculateCourses(
            courses: courses,
            progress: progress,
          );
          final overallMastery = masteryService.overallMastery(mastery);
          final badges = const AchievementService().buildBadges(
            mastery: mastery,
            progress: progress,
            activity: activity,
          );
          final unlockedBadges = badges.where((badge) => badge.unlocked).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'সম্পন্ন',
                      value: '$completed/${lessons.length}',
                      icon: Icons.verified_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: 'Mastery',
                      value: '$overallMastery%',
                      icon: Icons.psychology_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Avg Score',
                      value: '$average%',
                      icon: Icons.insights_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatTile(
                      label: 'Streak',
                      value: '${activity.currentStreak} দিন',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Course Mastery',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              for (final item in mastery) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text('${item.masteryScore}%'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: item.masteryScore / 100),
                        const SizedBox(height: 8),
                        Text(
                          '${item.completedLessons}/${item.totalLessons} lesson • Practical ${item.practicalAverage}% • ${item.levelLabel}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              Text(
                'Badges ($unlockedBadges/${badges.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final badge in badges)
                    _BadgeChip(
                      icon: badge.icon,
                      title: badge.title,
                      unlocked: badge.unlocked,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Final Certification',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        finalExamScore > 0
                            ? 'Best Final Exam Score: $finalExamScore%'
                            : 'Final practical exam এখনও pass করা হয়নি।',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FinalExamScreen(
                                      contentRepository: contentRepository,
                                      progressRepository: progressRepository,
                                      certificationRepository: certificationRepository,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fact_check_rounded),
                              label: const Text('Final Exam'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CertificateScreen(
                                      contentRepository: contentRepository,
                                      progressRepository: progressRepository,
                                      profileRepository: profileRepository,
                                      certificationRepository: certificationRepository,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.workspace_premium_rounded),
                              label: const Text('Certificate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.title,
    required this.unlocked,
  });

  final String icon;
  final String title;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.38,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 7),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            if (unlocked) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_circle_rounded, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}
