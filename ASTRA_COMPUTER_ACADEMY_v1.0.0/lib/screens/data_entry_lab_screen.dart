import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class DataEntryLabScreen extends StatefulWidget {
  const DataEntryLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<DataEntryLabScreen> createState() => _DataEntryLabScreenState();
}

class _DataEntryLabScreenState extends State<DataEntryLabScreen> {
  final Map<String, TextEditingController> _controllers = {};
  DateTime? _startedAt;
  bool _submitting = false;

  List<Map<String, dynamic>> get _fields {
    final raw = widget.lesson.practicalData['fields'] as List<dynamic>? ?? const [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  String get _taskTitle =>
      widget.lesson.practicalData['taskTitle'] as String? ?? 'Data Entry Task';
  String get _instruction => widget.lesson.practicalData['instruction'] as String? ??
      'Source Data দেখে প্রতিটি field হুবহু entry করুন।';
  double? get _targetMinutes =>
      (widget.lesson.practicalData['targetMinutes'] as num?)?.toDouble();

  @override
  void initState() {
    super.initState();
    for (final field in _fields) {
      final controller = TextEditingController();
      controller.addListener(() {
        if (controller.text.isNotEmpty && _startedAt == null && mounted) {
          setState(() => _startedAt = DateTime.now());
        }
      });
      _controllers[field['key'] as String] = controller;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _normalize(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final end = DateTime.now();
    final start = _startedAt ?? end;
    final seconds = end.difference(start).inMilliseconds / 1000.0;
    final minutes = seconds <= 0 ? 1 / 60 : seconds / 60;

    var correct = 0;
    final wrongFields = <String>[];
    for (final field in _fields) {
      final key = field['key'] as String;
      final expected = field['value'] as String;
      final actual = _controllers[key]?.text ?? '';
      if (_normalize(actual) == _normalize(expected)) {
        correct++;
      } else {
        wrongFields.add(field['label'] as String);
      }
    }

    final accuracy = _fields.isEmpty ? 0 : ((correct / _fields.length) * 100).round();
    final entriesPerMinute = _fields.isEmpty ? 0 : (correct / minutes);
    final target = _targetMinutes;
    final speedScore = target == null
        ? 100
        : ((target / minutes) * 100).clamp(0, 100).round();
    final skillScore = target == null
        ? accuracy
        : ((accuracy * 0.8) + (speedScore * 0.2)).round();
    final targetMet = accuracy == 100 && (target == null || minutes <= target);

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'data_entry',
      score: skillScore,
      metrics: {
        'accuracy': accuracy,
        'correctFields': correct,
        'totalFields': _fields.length,
        'wrongFields': wrongFields,
        'seconds': seconds.round(),
        'entriesPerMinute': double.parse(entriesPerMinute.toStringAsFixed(2)),
        'targetMinutes': target,
        'targetMet': targetMet,
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    final wrongText = wrongFields.isEmpty
        ? 'কোনো field ভুল নেই।'
        : 'ভুল field: ${wrongFields.join(', ')}';
    final timeText = seconds < 60
        ? '${seconds.round()} sec'
        : '${minutes.toStringAsFixed(1)} min';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Data Entry Result — $skillScore%'),
        content: Text(
          'Accuracy: $accuracy%\n'
          'Correct: $correct / ${_fields.length}\n'
          'Time: $timeText\n'
          'Entries/min: ${entriesPerMinute.toStringAsFixed(1)}\n'
          '${target == null ? '' : 'Target time: ${target.toStringAsFixed(target % 1 == 0 ? 0 : 1)} min\n'}'
          '$wrongText',
        ),
        actions: [
          if (!targetMet)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('আবার চেষ্টা করুন'),
            ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Entry Lab')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            _taskTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(_instruction),
          if (_targetMinutes != null) ...[
            const SizedBox(height: 6),
            Text('Target: 100% accuracy within ${_targetMinutes!.toStringAsFixed(_targetMinutes! % 1 == 0 ? 0 : 1)} min'),
          ],
          const SizedBox(height: 18),
          Text(
            'Source Data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final field in _fields)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 105,
                            child: Text(
                              '${field['label']}:',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Expanded(child: Text(field['value'] as String)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Entry Form',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          for (final field in _fields) ...[
            TextField(
              controller: _controllers[field['key'] as String],
              decoration: InputDecoration(labelText: field['label'] as String),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Entry যাচাই করুন'),
        ),
      ),
    );
  }
}
