import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';
import 'lesson_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.progressRepository,
  });

  final Course course;
  final ProgressRepository progressRepository;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Map<String, LessonProgress> _progress = const {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final result = await widget.progressRepository.getAllProgress();
    if (mounted) setState(() => _progress = result);
  }

  bool _isUnlocked(Lesson lesson) {
    final index = widget.course.lessons.indexWhere((item) => item.id == lesson.id);
    if (index <= 0) return true;
    if (_progress[lesson.id]?.completed == true) return true;
    return _progress[widget.course.lessons[index - 1].id]?.completed == true;
  }

  Future<void> _openLesson(Lesson lesson) async {
    if (!_isUnlocked(lesson)) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lesson: lesson,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.course.lessons.where((item) => !item.isPractical).toList();
    final practicals = widget.course.lessons.where((item) => item.isPractical).toList();
    final completed = widget.course.lessons
        .where((item) => _progress[item.id]?.completed == true)
        .length;
    final total = widget.course.lessons.length;
    final value = total == 0 ? 0.0 : completed / total;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.course.titleBn),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Lessons'),
              Tab(text: 'Practicals'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppTheme.navy,
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Text(widget.course.icon, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.course.subtitleBn,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$completed/$total complete',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(value * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      color: const Color(0xFF3D9BFF),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _LessonList(
                    lessons: lessons,
                    progress: _progress,
                    isUnlocked: _isUnlocked,
                    onTap: _openLesson,
                  ),
                  _LessonList(
                    lessons: practicals,
                    progress: _progress,
                    isUnlocked: _isUnlocked,
                    onTap: _openLesson,
                    practicalMode: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonList extends StatelessWidget {
  const _LessonList({
    required this.lessons,
    required this.progress,
    required this.isUnlocked,
    required this.onTap,
    this.practicalMode = false,
  });

  final List<Lesson> lessons;
  final Map<String, LessonProgress> progress;
  final bool Function(Lesson lesson) isUnlocked;
  final ValueChanged<Lesson> onTap;
  final bool practicalMode;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return Center(
        child: Text(practicalMode ? 'এই কোর্সে আলাদা practical নেই' : 'Lesson নেই'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        final itemProgress = progress[lesson.id];
        final completed = itemProgress?.completed == true;
        final unlocked = isUnlocked(lesson);
        final score = itemProgress?.bestScore ?? 0;

        return Card(
          child: ListTile(
            enabled: unlocked,
            onTap: unlocked ? () => onTap(lesson) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: completed
                    ? AppTheme.success.withValues(alpha: .10)
                    : AppTheme.royalBlue.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: completed
                  ? const Icon(Icons.check_rounded, color: AppTheme.success)
                  : unlocked
                      ? Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.royalBlue,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(Icons.lock_rounded, size: 18, color: AppTheme.muted),
            ),
            title: Text(
              lesson.titleBn,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              unlocked
                  ? '${lesson.durationMinutes} min • ${lesson.isPractical ? 'Practical' : 'Theory'}'
                      '${score > 0 ? ' • Best $score%' : ''}'
                  : 'আগের lesson সম্পন্ন করলে unlock হবে',
            ),
            trailing: Icon(
              unlocked ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
              color: unlocked ? AppTheme.muted : AppTheme.muted,
            ),
          ),
        );
      },
    );
  }
}
