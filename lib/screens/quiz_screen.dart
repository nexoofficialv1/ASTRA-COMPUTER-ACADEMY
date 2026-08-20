import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _index = 0;
  int _correct = 0;
  int? _selected;
  bool _answered = false;

  Future<void> _next() async {
    final question = widget.lesson.quiz[_index];
    if (_selected == question.correctIndex) _correct++;

    if (_index == widget.lesson.quiz.length - 1) {
      final score = ((_correct / widget.lesson.quiz.length) * 100).round();
      await widget.progressRepository.markCompleted(widget.lesson.id, score: score);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Quiz সম্পন্ন'),
          content: Text('আপনার স্কোর: $score%'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('শেষ করুন'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _index++;
      _selected = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.lesson.quiz[_index];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz ${_index + 1}/${widget.lesson.quiz.length}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          LinearProgressIndicator(value: (_index + 1) / widget.lesson.quiz.length),
          const SizedBox(height: 24),
          Text(
            question.question,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (question.questionEn.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              question.questionEn,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
          const SizedBox(height: 18),
          RadioGroup<int>(
            groupValue: _selected,
            onChanged: (value) {
              if (!_answered) setState(() => _selected = value);
            },
            child: Column(
              children: [
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: RadioListTile<int>(
                      value: i,
                      enabled: !_answered,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(question.options[i]),
                          if (i < question.optionsEn.length &&
                              question.optionsEn[i].trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                question.optionsEn[i],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_answered) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(question.explanation),
                    if (question.explanationEn.trim().isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        'English Explanation',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(question.explanationEn),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _selected == null
              ? null
              : () {
                  if (!_answered) {
                    setState(() => _answered = true);
                  } else {
                    _next();
                  }
                },
          child: Text(_answered ? 'পরবর্তী' : 'উত্তর যাচাই করুন'),
        ),
      ),
    );
  }
}
