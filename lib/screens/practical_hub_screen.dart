import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/content_repository.dart';
import '../services/progress_repository.dart';
import 'lesson_screen.dart';

class PracticalHubScreen extends StatefulWidget {
  const PracticalHubScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;

  @override
  State<PracticalHubScreen> createState() => _PracticalHubScreenState();
}

class _PracticalHubScreenState extends State<PracticalHubScreen> {
  Map<String, LessonProgress> _progress = const {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final progress = await widget.progressRepository.getAllProgress();
    if (mounted) setState(() => _progress = progress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practical Lab')),
      body: FutureBuilder<List<Course>>(
        future: widget.contentRepository.loadCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          final items = <({Course course, Lesson lesson})>[];
          for (final course in courses) {
            for (final lesson in course.lessons.where((item) => item.isPractical)) {
              items.add((course: course, lesson: lesson));
            }
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.navy, AppTheme.royalBlue],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science_rounded, color: Colors.white, size: 38),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Practice by doing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} interactive practical available offline',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              for (final item in items) ...[
                _PracticalTile(
                  course: item.course,
                  lesson: item.lesson,
                  progress: _progress[item.lesson.id],
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(
                          lesson: item.lesson,
                          progressRepository: widget.progressRepository,
                        ),
                      ),
                    );
                    _reload();
                  },
                ),
                const SizedBox(height: 9),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PracticalTile extends StatelessWidget {
  const _PracticalTile({
    required this.course,
    required this.lesson,
    required this.progress,
    required this.onTap,
  });

  final Course course;
  final Lesson lesson;
  final LessonProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = progress?.completed == true;
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.royalBlue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(course.icon, style: const TextStyle(fontSize: 21)),
        ),
        title: Text(lesson.titleBn, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(
          '${course.titleBn} • ${lesson.durationMinutes} min'
          '${(progress?.bestScore ?? 0) > 0 ? ' • Best ${progress!.bestScore}%' : ''}',
        ),
        trailing: Icon(
          completed ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded,
          color: completed ? AppTheme.success : AppTheme.royalBlue,
        ),
      ),
    );
  }
}
