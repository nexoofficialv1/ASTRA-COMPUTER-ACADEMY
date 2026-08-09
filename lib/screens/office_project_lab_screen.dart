import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class OfficeProjectLabScreen extends StatefulWidget {
  const OfficeProjectLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<OfficeProjectLabScreen> createState() => _OfficeProjectLabScreenState();
}

class _OfficeProjectLabScreenState extends State<OfficeProjectLabScreen> {
  final Map<String, TextEditingController> _controllers = {};

  List<Map<String, dynamic>> get _tasks =>
      (widget.lesson.practicalData['tasks'] as List<dynamic>? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  @override
  void initState() {
    super.initState();
    for (final task in _tasks) {
      _controllers[task['id'] as String] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isCorrect(Map<String, dynamic> task) {
    final value = _controllers[task['id']]!.text.trim();
    final expected = (task['expected'] as String? ?? '').trim();
    final mode = task['match'] as String? ?? 'exact';
    if (mode == 'contains') {
      return value.toLowerCase().contains(expected.toLowerCase());
    }
    if (mode == 'formula') {
      return value.replaceAll(' ', '').toUpperCase() ==
          expected.replaceAll(' ', '').toUpperCase();
    }
    return value.toLowerCase() == expected.toLowerCase();
  }

  Future<void> _submit() async {
    final checks = [for (final task in _tasks) _isCorrect(task)];
    final passed = checks.where((x) => x).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'office_project',
      score: score,
      metrics: {
        'tasks': _tasks.length,
        'passedTasks': passed,
        'answers': {
          for (final task in _tasks)
            task['id'] as String: _controllers[task['id']]!.text.trim(),
        },
      },
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Project Score: $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _tasks.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(checks[i] ? Icons.check_circle_rounded : Icons.cancel_rounded),
                title: Text(_tasks[i]['label'] as String? ?? 'Task'),
              ),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে')),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.lesson.practicalData['projectTitle'] as String? ?? 'Office Project';
    final instruction = widget.lesson.practicalData['instruction'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.titleBn)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(instruction),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < _tasks.length; i++) ...[
            Text(
              '${i + 1}. ${_tasks[i]['label']}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(_tasks[i]['prompt'] as String? ?? ''),
            const SizedBox(height: 8),
            TextField(
              controller: _controllers[_tasks[i]['id']],
              minLines: _tasks[i]['multiline'] == true ? 3 : 1,
              maxLines: _tasks[i]['multiline'] == true ? 5 : 1,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: _tasks[i]['hint'] as String? ?? 'আপনার উত্তর লিখুন',
              ),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.assignment_turned_in_rounded),
          label: const Text('Project জমা দিন'),
        ),
      ),
    );
  }
}
