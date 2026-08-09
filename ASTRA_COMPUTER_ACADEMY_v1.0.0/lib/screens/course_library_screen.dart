import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course.dart';
import '../services/content_repository.dart';
import '../services/progress_repository.dart';
import '../widgets/course_card.dart';
import 'course_detail_screen.dart';

class CourseLibraryScreen extends StatefulWidget {
  const CourseLibraryScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;

  @override
  State<CourseLibraryScreen> createState() => _CourseLibraryScreenState();
}

class _CourseLibraryScreenState extends State<CourseLibraryScreen> {
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

  int _completed(Course course) => course.lessons
      .where((lesson) => _progress[lesson.id]?.completed == true)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: widget.contentRepository.loadCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Courses',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Theory ও Practical মিলিয়ে ধাপে ধাপে শিখুন',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlue.withOpacity(.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${courses.length} Courses',
                      style: const TextStyle(
                        color: AppTheme.royalBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (final course in courses) ...[
                CourseCard(
                  compact: true,
                  course: course,
                  completedLessons: _completed(course),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(
                          course: course,
                          progressRepository: widget.progressRepository,
                        ),
                      ),
                    );
                    _reload();
                  },
                ),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}
