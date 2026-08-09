import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/certification_repository.dart';
import '../services/content_repository.dart';
import '../services/final_exam_service.dart';
import '../services/progress_repository.dart';
import 'lesson_screen.dart';

class FinalExamScreen extends StatefulWidget {
  const FinalExamScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
    required this.certificationRepository,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final CertificationRepository certificationRepository;

  @override
  State<FinalExamScreen> createState() => _FinalExamScreenState();
}

class _FinalExamScreenState extends State<FinalExamScreen> {
  final _examService = const FinalExamService();
  List<Course> _courses = const [];
  Map<String, LessonProgress> _progress = const {};
  bool _loading = true;
  bool _saving = false;
  FinalExamResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final results = await Future.wait<dynamic>([
      widget.contentRepository.loadCourses(),
      widget.progressRepository.getAllProgress(),
    ]);
    if (!mounted) return;
    setState(() {
      _courses = results[0] as List<Course>;
      _progress = results[1] as Map<String, LessonProgress>;
      _loading = false;
    });
  }

  Future<void> _openComponent(FinalExamComponent component) async {
    final lesson = _examService.findLesson(_courses, component.lessonId);
    if (lesson == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lesson: lesson,
          progressRepository: widget.progressRepository,
        ),
      ),
    );
    await _reload();
  }

  Future<void> _evaluate() async {
    final result = _examService.evaluate(_progress);
    setState(() {
      _saving = true;
      _lastResult = result;
    });
    await widget.certificationRepository.recordFinalExam(
      score: result.score,
      passed: result.passed,
      componentScores: result.componentScores,
    );
    if (!mounted) return;
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final liveResult = _examService.evaluate(_progress);
    final result = _lastResult ?? liveResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Final Practical Exam')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Computer & Office Skills',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${FinalExamService.components.length}টি core practical সম্পন্ন করুন। প্রতিটি component-এ কমপক্ষে 60% এবং overall 70% পেলে Final Exam pass হবে।',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < FinalExamService.components.length; i++) ...[
            Builder(
              builder: (context) {
                final component = FinalExamService.components[i];
                final score = _progress[component.lessonId]?.bestScore ?? 0;
                final passed = score >= component.minimumScore;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      child: passed
                          ? const Icon(Icons.check_rounded)
                          : Text('${i + 1}'),
                    ),
                    title: Text(
                      component.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      score == 0
                          ? 'Not attempted • Minimum ${component.minimumScore}%'
                          : 'Best $score% • Minimum ${component.minimumScore}%',
                    ),
                    trailing: const Icon(Icons.play_circle_outline_rounded),
                    onTap: () => _openComponent(component),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _evaluate,
            icon: const Icon(Icons.fact_check_rounded),
            label: Text(_saving ? 'Result সংরক্ষণ হচ্ছে...' : 'Final Result Evaluate করুন'),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    result.passed ? Icons.verified_rounded : Icons.pending_actions_rounded,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.passed ? 'PASS' : 'NOT PASSED YET',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        Text('Current Final Score: ${result.score}%'),
                        if (!result.allComponentsAttempted)
                          const Text('সব component এখনও attempt করা হয়নি।'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
