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

  Future<void> _openCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          course: course,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: widget.contentRepository.loadAllCourses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final courses = snapshot.data!;
          final schoolCourses =
              courses.where((course) => course.isSchoolCourse).toList();
          final skillCourses =
              courses.where((course) => !course.isSchoolCourse).toList();

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
                          'School learning ও practical skill—দুই track-এ শিখুন',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.royalBlue.withValues(alpha: .10),
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
              if (schoolCourses.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionHeading(
                  icon: Icons.school_rounded,
                  title: 'School Courses',
                  subtitle:
                      'Class V • Computer Science • Cursor Pro syllabus-aligned',
                  badge: '${schoolCourses.length} chapters',
                ),
                const SizedBox(height: 12),
                for (final course in schoolCourses) ...[
                  CourseCard(
                    compact: true,
                    course: course,
                    completedLessons: _completed(course),
                    onTap: () => _openCourse(course),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
              if (skillCourses.isNotEmpty) ...[
                const SizedBox(height: 22),
                _SectionHeading(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Skill Courses',
                  subtitle: 'Basic Computer, Office, Typing ও practical mastery',
                  badge: '${skillCourses.length} courses',
                ),
                const SizedBox(height: 12),
                for (final course in skillCourses) ...[
                  CourseCard(
                    compact: true,
                    course: course,
                    completedLessons: _completed(course),
                    onTap: () => _openCourse(course),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppTheme.royalBlue.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppTheme.royalBlue),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          badge,
          style: const TextStyle(
            color: AppTheme.royalBlue,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
