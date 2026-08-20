import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/progress_repository.dart';
import '../services/school_assessment_service.dart';

class ChapterTestScreen extends StatefulWidget {
  const ChapterTestScreen({
    super.key,
    required this.course,
    required this.progressRepository,
  });

  final Course course;
  final ProgressRepository progressRepository;

  @override
  State<ChapterTestScreen> createState() => _ChapterTestScreenState();
}

class _ChapterTestScreenState extends State<ChapterTestScreen> {
  static const _service = SchoolAssessmentService();
  final Map<int, int> _answers = {};
  bool _submitted = false;
  bool _saving = false;
  int _score = 0;

  Future<void> _submit() async {
    final questions = _service.chapterQuestions(widget.course);
    if (_saving || _answers.length != questions.length) return;
    final score = _service.scoreQuiz(
      questions: questions,
      answers: _answers,
    );
    setState(() {
      _saving = true;
      _score = score;
    });
    await widget.progressRepository.markCompleted(
      SchoolAssessmentService.chapterTestId(widget.course),
      score: score,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _submitted = true;
    });
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
    final questions = _service.chapterQuestions(widget.course);
    final passed = _score >= SchoolAssessmentService.chapterPassScore;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.course.titleBn} • Chapter Test')),
      body: questions.isEmpty
          ? const Center(child: Text('এই chapter-এ test question নেই।'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chapter Test',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${questions.length} questions • Pass ${SchoolAssessmentService.chapterPassScore}%',
                        ),
                        if (_submitted) ...[
                          const SizedBox(height: 12),
                          Text(
                            passed
                                ? 'PASS • $_score%'
                                : 'RETRY NEEDED • $_score%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < questions.length; i++) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ${questions[i].question}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (var option = 0;
                              option < questions[i].options.length;
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
                              title: Text(questions[i].options[option]),
                            ),
                          if (_submitted) ...[
                            const Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  _answers[i] == questions[i].correctIndex
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(questions[i].explanation),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
      bottomNavigationBar: questions.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: _submitted
                  ? FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Retake Chapter Test'),
                    )
                  : FilledButton.icon(
                      onPressed: _saving || _answers.length != questions.length
                          ? null
                          : _submit,
                      icon: const Icon(Icons.fact_check_rounded),
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
