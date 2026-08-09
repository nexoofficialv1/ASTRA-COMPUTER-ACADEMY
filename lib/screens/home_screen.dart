import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/course.dart';
import '../models/learner_profile.dart';
import '../models/lesson.dart';
import '../services/backup_restore_service.dart';
import '../services/certification_repository.dart';
import '../services/content_repository.dart';
import '../services/learner_profile_repository.dart';
import '../services/progress_repository.dart';
import '../widgets/brand_mark.dart';
import '../widgets/course_card.dart';
import '../widgets/progress_ring.dart';
import 'course_detail_screen.dart';
import 'course_library_screen.dart';
import 'data_tools_screen.dart';
import 'lesson_screen.dart';
import 'practical_hub_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
    required this.profileRepository,
    required this.certificationRepository,
    required this.backupRestoreService,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final LearnerProfileRepository profileRepository;
  final CertificationRepository certificationRepository;
  final BackupRestoreService backupRestoreService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Course>> _coursesFuture;
  Map<String, LessonProgress> _progress = const {};
  LearnerProfile? _profile;
  LearningActivityStats _activity = const LearningActivityStats(
    currentStreak: 0,
    longestStreak: 0,
    activeDays: 0,
  );

  @override
  void initState() {
    super.initState();
    _coursesFuture = widget.contentRepository.loadCourses();
    _reloadStatus();
  }

  Future<void> _reloadStatus() async {
    final results = await Future.wait<dynamic>([
      widget.progressRepository.getAllProgress(),
      widget.progressRepository.getActivityStats(),
      widget.profileRepository.getProfile(),
    ]);
    if (!mounted) return;
    setState(() {
      _progress = results[0] as Map<String, LessonProgress>;
      _activity = results[1] as LearningActivityStats;
      _profile = results[2] as LearnerProfile?;
    });
  }

  int _completedCount(Course course) => course.lessons
      .where((lesson) => _progress[lesson.id]?.completed == true)
      .length;

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(profileRepository: widget.profileRepository),
      ),
    );
    _reloadStatus();
  }

  Future<void> _openProgress() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProgressScreen(
          contentRepository: widget.contentRepository,
          progressRepository: widget.progressRepository,
          profileRepository: widget.profileRepository,
          certificationRepository: widget.certificationRepository,
        ),
      ),
    );
    _reloadStatus();
  }

  Future<void> _openDataTools() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DataToolsScreen(
          backupRestoreService: widget.backupRestoreService,
        ),
      ),
    );
    _reloadStatus();
  }

  Future<void> _openCourseLibrary() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseLibraryScreen(
          contentRepository: widget.contentRepository,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reloadStatus();
  }

  Future<void> _openPracticalHub() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PracticalHubScreen(
          contentRepository: widget.contentRepository,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reloadStatus();
  }

  Future<void> _openCourse(Course course) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(
          course: course,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reloadStatus();
  }

  void _bottomNavigation(int index) {
    switch (index) {
      case 1:
        _openCourseLibrary();
        break;
      case 2:
        _openPracticalHub();
        break;
      case 3:
        _openProgress();
        break;
      case 4:
        _openProfile();
        break;
    }
  }

  Lesson? _nextLesson(List<Course> courses) {
    for (final course in courses) {
      for (final lesson in course.lessons) {
        if (_progress[lesson.id]?.completed != true) return lesson;
      }
    }
    return courses.isEmpty || courses.first.lessons.isEmpty
        ? null
        : courses.first.lessons.first;
  }

  Course? _courseForLesson(List<Course> courses, Lesson lesson) {
    for (final course in courses) {
      if (course.lessons.any((item) => item.id == lesson.id)) return course;
    }
    return null;
  }

  Future<void> _openLesson(Lesson lesson) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lesson: lesson,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BrandMark(compact: true, inverse: true),
        actions: [
          IconButton(
            tooltip: 'Backup & Restore',
            onPressed: _openDataTools,
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: _openProfile,
            icon: const Icon(Icons.account_circle_rounded),
          ),
          const SizedBox(width: 5),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _bottomNavigation,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.science_rounded), label: 'Practical'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('কনটেন্ট লোড করা যায়নি: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? const <Course>[];
          final totalLessons = courses.fold<int>(0, (sum, c) => sum + c.lessons.length);
          final completed = courses.fold<int>(0, (sum, c) => sum + _completedCount(c));
          final overall = totalLessons == 0 ? 0.0 : completed / totalLessons;
          final nextLesson = _nextLesson(courses);
          final nextCourse = nextLesson == null ? null : _courseForLesson(courses, nextLesson);
          final practicalCount = courses
              .expand((course) => course.lessons)
              .where((lesson) => lesson.isPractical)
              .length;

          return RefreshIndicator(
            onRefresh: _reloadStatus,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _WelcomeCard(
                  name: _profile?.isComplete == true ? _profile!.name : 'Learner',
                  onProfileTap: _openProfile,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final narrow = constraints.maxWidth < 390;
                    final streak = _StreakCard(
                      current: _activity.currentStreak,
                      longest: _activity.longestStreak,
                    );
                    final offline = _OfflineCard(
                      lessons: totalLessons,
                      practicals: practicalCount,
                    );
                    if (narrow) {
                      return Column(
                        children: [
                          streak,
                          const SizedBox(height: 10),
                          offline,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: streak),
                        const SizedBox(width: 10),
                        Expanded(child: offline),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(17),
                    child: Row(
                      children: [
                        ProgressRing(value: overall),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$completed of $totalLessons lessons completed',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 9),
                              InkWell(
                                onTap: _openProgress,
                                child: const Text(
                                  'View detailed progress  ›',
                                  style: TextStyle(
                                    color: AppTheme.royalBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (nextLesson != null) ...[
                  const SizedBox(height: 22),
                  _SectionHeader(
                    title: 'Continue Learning',
                    action: 'View course',
                    onTap: nextCourse == null ? null : () => _openCourse(nextCourse),
                  ),
                  const SizedBox(height: 10),
                  _ContinueCard(
                    lesson: nextLesson,
                    course: nextCourse,
                    progress: _progress[nextLesson.id],
                    onTap: () => _openLesson(nextLesson),
                  ),
                ],
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Courses',
                  action: 'View all',
                  onTap: _openCourseLibrary,
                ),
                const SizedBox(height: 10),
                for (final course in courses.take(5)) ...[
                  CourseCard(
                    compact: true,
                    course: course,
                    completedLessons: _completedCount(course),
                    onTap: () => _openCourse(course),
                  ),
                  const SizedBox(height: 9),
                ],
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openPracticalHub,
                  icon: const Icon(Icons.science_rounded),
                  label: const Text('Open Practical Lab'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.name, required this.onProfileTap});
  final String name;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onProfileTap,
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: AppTheme.royalBlue),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $name!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Keep learning every day',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current, required this.longest});
  final int current;
  final int longest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFE3AE)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 25)),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Streak',
                  style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w900),
                ),
                Text(
                  '$current days • Best $longest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard({required this.lessons, required this.practicals});
  final int lessons;
  final int practicals;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4E7FF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt_rounded, color: AppTheme.royalBlue, size: 28),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offline Ready',
                  style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w900),
                ),
                Text(
                  '$lessons lessons • $practicals labs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, this.onTap});
  final String title;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({
    required this.lesson,
    required this.course,
    required this.progress,
    required this.onTap,
  });

  final Lesson lesson;
  final Course? course;
  final LessonProgress? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.navy, Color(0xFF12398F)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 350;
          final icon = Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(course?.icon ?? '💻', style: const TextStyle(fontSize: 24)),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course?.titleBn ?? 'Basic Computer',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                lesson.titleBn,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${lesson.durationMinutes} min • ${lesson.isPractical ? 'Practical' : 'Theory'}'
                '${(progress?.bestScore ?? 0) > 0 ? ' • Best ${progress!.bestScore}%' : ''}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
          final button = FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.royalBlue,
              minimumSize: const Size(76, 42),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: onTap,
            child: const Text('Continue'),
          );
          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: 13),
                    Expanded(child: details),
                  ],
                ),
                const SizedBox(height: 12),
                button,
              ],
            );
          }
          return Row(
            children: [
              icon,
              const SizedBox(width: 13),
              Expanded(child: details),
              const SizedBox(width: 8),
              button,
            ],
          );
        },
      ),
    );
  }
}
