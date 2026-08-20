import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class ConceptSortLabScreen extends StatefulWidget {
  const ConceptSortLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<ConceptSortLabScreen> createState() => _ConceptSortLabScreenState();
}

class _ConceptSortLabScreenState extends State<ConceptSortLabScreen> {
  final Map<int, String> _answers = {};
  bool _saving = false;

  List<String> get _categories => List<String>.from(
        widget.lesson.practicalData['categories'] as List<dynamic>? ?? const [],
      );

  List<Map<String, dynamic>> get _items =>
      (widget.lesson.practicalData['items'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  Future<void> _evaluate() async {
    if (_saving || _answers.length != _items.length) return;
    var correct = 0;
    for (var i = 0; i < _items.length; i++) {
      if (_answers[i] == _items[i]['category']) correct++;
    }
    final score =
        _items.isEmpty ? 0 : ((correct / _items.length) * 100).round();

    setState(() => _saving = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'concept_sort',
      score: score,
      metrics: {
        'answers': {
          for (var i = 0; i < _items.length; i++)
            _items[i]['label'] as String: _answers[i],
        },
        'correct': correct,
        'total': _items.length,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Concept Sort — $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _items.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  _answers[i] == _items[i]['category']
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                ),
                title: Text(_items[i]['label'] as String),
                subtitle: Text(
                  'Correct: ${_items[i]['category']}',
                ),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction =
        widget.lesson.practicalData['instruction'] as String? ??
            'প্রতিটি item সঠিক category-তে রাখুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Concept Sort Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Text(
            instruction,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _items.length; i++) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _items[i]['label'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final category in _categories)
                          ChoiceChip(
                            label: Text(category),
                            selected: _answers[i] == category,
                            onSelected: (_) =>
                                setState(() => _answers[i] = category),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving || _answers.length != _items.length
              ? null
              : _evaluate,
          icon: const Icon(Icons.fact_check_rounded),
          label: Text(
            _saving
                ? 'Saving...'
                : 'Check ${_answers.length}/${_items.length}',
          ),
        ),
      ),
    );
  }
}
