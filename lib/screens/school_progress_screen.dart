import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/progress_repository.dart';
import '../services/school_assessment_service.dart';
import 'class5_final_exam_screen.dart';

class SchoolProgressScreen extends StatefulWidget {
  const SchoolProgressScreen({
    super.key,
    required this.courses,
    required this.progressRepository,
  });

  final List<Course> courses;
  final ProgressRepository progressRepository;

  @override
  State<SchoolProgressScreen> createState() => _SchoolProgressScreenState();
}

class _SchoolProgressScreenState extends State<SchoolProgressScreen> {
  Map<String, LessonProgress> _progress = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final progress = await widget.progressRepository.getAllProgress();
    if (!mounted) return;
    setState(() {
      _progress = progress;
      _loading = false;
    });
  }

  int _completed(Course course) => course.lessons
      .where((lesson) => _progress[lesson.id]?.completed == true)
      .length;

  int _chapterScore(Course course) =>
      _progress[SchoolAssessmentService.chapterTestId(course)]?.bestScore ?? 0;

  int _practicalAverage(Course course) {
    final scores = course.lessons
        .where((lesson) => lesson.isPractical)
        .map((lesson) => _progress[lesson.id]?.bestScore ?? 0)
        .where((score) => score > 0)
        .toList();
    if (scores.isEmpty) return 0;
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  Future<void> _openFinal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Class5FinalExamScreen(
          courses: widget.courses,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final courses =
        widget.courses.where((course) => course.isSchoolCourse).toList();
    final lessons = courses.expand((course) => course.lessons).toList();
    final completed =
        lessons.where((lesson) => _progress[lesson.id]?.completed == true).length;
    final chapterPassed = courses
        .where(
          (course) =>
              _chapterScore(course) >=
              SchoolAssessmentService.chapterPassScore,
        )
        .length;
    final finalScore =
        _progress[SchoolAssessmentService.class5FinalExamId]?.bestScore ?? 0;
    final overall =
        lessons.isEmpty ? 0 : ((completed / lessons.length) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Class V School Progress')),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Class V Computer Science',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: overall / 100,
                      minHeight: 9,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed/${lessons.length} lessons • $overall% learning progress',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$chapterPassed/${courses.length} chapter tests passed • Final best $finalScore%',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final course in courses) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.titleBn,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: course.lessons.isEmpty
                            ? 0
                            : _completed(course) / course.lessons.length,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lessons ${_completed(course)}/${course.lessons.length} • Practical avg ${_practicalAverage(course)}%',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chapter Test: ${_chapterScore(course)}% '
                        '${_chapterScore(course) >= SchoolAssessmentService.chapterPassScore ? '• PASS' : '• Pending/Retry'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 9),
            ],
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _openFinal,
              icon: const Icon(Icons.fact_check_rounded),
              label: Text(
                finalScore >= SchoolAssessmentService.finalPassScore
                    ? 'Final Exam • PASS $finalScore%'
                    : 'Open Class V Final Exam',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
