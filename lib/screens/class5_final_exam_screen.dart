import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/progress_repository.dart';
import '../services/school_assessment_service.dart';

class Class5FinalExamScreen extends StatefulWidget {
  const Class5FinalExamScreen({
    super.key,
    required this.courses,
    required this.progressRepository,
  });

  final List<Course> courses;
  final ProgressRepository progressRepository;

  @override
  State<Class5FinalExamScreen> createState() => _Class5FinalExamScreenState();
}

class _Class5FinalExamScreenState extends State<Class5FinalExamScreen> {
  static const _service = SchoolAssessmentService();
  final Map<int, int> _answers = {};
  Map<String, LessonProgress> _progress = const {};
  bool _loading = true;
  bool _saving = false;
  bool _submitted = false;
  int _score = 0;

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

  bool _chapterPassed(Course course) {
    final score = _progress[
                SchoolAssessmentService.chapterTestId(course)]
            ?.bestScore ??
        0;
    return score >= SchoolAssessmentService.chapterPassScore;
  }

  List<Course> get _missingChapters => widget.courses
      .where((course) => course.isSchoolCourse && !_chapterPassed(course))
      .toList();

  Future<void> _submit() async {
    final questions = _service.finalQuestions(widget.courses);
    if (_saving || _answers.length != questions.length) return;
    final score = _service.scoreFinal(
      questions: questions,
      answers: _answers,
    );
    setState(() {
      _saving = true;
      _score = score;
    });
    await widget.progressRepository.markCompleted(
      SchoolAssessmentService.class5FinalExamId,
      score: score,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _submitted = true;
    });
    await _reload();
  }

  void _retry() {
    setState(() {
      _answers.clear();
      _submitted = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final questions = _service.finalQuestions(widget.courses);
    final missing = _missingChapters;
    final ready = missing.isEmpty && questions.isNotEmpty;
    final passed = _score >= SchoolAssessmentService.finalPassScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Class V Final Exam')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Class V Computer Science Final Exam',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${questions.length} chapters/questions • Pass ${SchoolAssessmentService.finalPassScore}%',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ready
                        ? 'All chapter tests passed. Final Exam unlocked.'
                        : 'Final Exam unlock করতে সব Chapter Test-এ কমপক্ষে ${SchoolAssessmentService.chapterPassScore}% পেতে হবে।',
                  ),
                  if (_submitted) ...[
                    const SizedBox(height: 10),
                    Text(
                      passed
                          ? 'FINAL RESULT: PASS • $_score%'
                          : 'FINAL RESULT: RETAKE • $_score%',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!ready) ...[
            const SizedBox(height: 12),
            const Text(
              'Pending Chapter Tests',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final course in missing)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock_clock_rounded),
                  title: Text(course.titleBn),
                  subtitle: Text(
                    'Best ${_progress[SchoolAssessmentService.chapterTestId(course)]?.bestScore ?? 0}%',
                  ),
                ),
              ),
          ] else ...[
            const SizedBox(height: 12),
            for (var i = 0; i < questions.length; i++) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questions[i].chapterTitle,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${i + 1}. ${questions[i].question.question}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      for (var option = 0;
                          option < questions[i].question.options.length;
                          option++)
                        RadioListTile<int>(
                          contentPadding: EdgeInsets.zero,
                          value: option,
                          groupValue: _answers[i],
                          onChanged: _submitted
                              ? null
                              : (value) {
                                  if (value == null) return;
                                  setState(() => _answers[i] = value);
                                },
                          title: Text(
                            questions[i].question.options[option],
                          ),
                        ),
                      if (_submitted) ...[
                        const Divider(),
                        Text(questions[i].question.explanation),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
      bottomNavigationBar: !ready
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: _submitted
                  ? FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Retake Final Exam'),
                    )
                  : FilledButton.icon(
                      onPressed: _saving || _answers.length != questions.length
                          ? null
                          : _submit,
                      icon: const Icon(Icons.school_rounded),
                      label: Text(
                        _saving
                            ? 'Saving...'
                            : 'Submit ${_answers.length}/${questions.length}',
                      ),
                    ),
            ),
    );
  }
}
