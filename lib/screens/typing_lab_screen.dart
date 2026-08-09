import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class TypingLabScreen extends StatefulWidget {
  const TypingLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<TypingLabScreen> createState() => _TypingLabScreenState();
}

class _TypingLabScreenState extends State<TypingLabScreen> {
  final _controller = TextEditingController();
  DateTime? _startedAt;
  bool _submitting = false;

  String get _target => widget.lesson.practicalData['targetText'] as String? ?? '';
  String get _taskTitle =>
      widget.lesson.practicalData['taskTitle'] as String? ?? 'Typing Practice';
  int get _targetWpm =>
      (widget.lesson.practicalData['targetWpm'] as num?)?.round() ?? 20;
  int get _targetAccuracy =>
      (widget.lesson.practicalData['targetAccuracy'] as num?)?.round() ?? 90;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (value.isNotEmpty && _startedAt == null) {
      setState(() => _startedAt = DateTime.now());
    }
  }

  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 0; i < a.length; i++) {
      final current = <int>[i + 1];
      for (var j = 0; j < b.length; j++) {
        final insert = current[j] + 1;
        final delete = previous[j + 1] + 1;
        final replace = previous[j] + (a[i] == b[j] ? 0 : 1);
        current.add([insert, delete, replace].reduce((x, y) => x < y ? x : y));
      }
      previous = current;
    }
    return previous.last;
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty || _submitting) return;
    setState(() => _submitting = true);

    final end = DateTime.now();
    final start = _startedAt ?? end;
    final seconds = end.difference(start).inMilliseconds / 1000.0;
    final minutes = seconds <= 0 ? 1 / 60 : seconds / 60;
    final typed = _controller.text.trim();
    final target = _target.trim();
    final maxLength = target.length > typed.length ? target.length : typed.length;
    final distance = _levenshtein(target, typed);
    final accuracy = maxLength == 0
        ? 100
        : ((1 - (distance / maxLength)) * 100).clamp(0, 100).round();
    final words = typed.isEmpty ? 0 : typed.split(RegExp(r'\s+')).length;
    final wpm = (words / minutes).round();
    final speedScore = ((wpm / _targetWpm) * 100).clamp(0, 100).round();
    final skillScore = ((accuracy * 0.7) + (speedScore * 0.3)).round();
    final targetMet = accuracy >= _targetAccuracy && wpm >= _targetWpm;

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'typing',
      score: skillScore,
      metrics: {
        'accuracy': accuracy,
        'wpm': wpm,
        'targetWpm': _targetWpm,
        'targetAccuracy': _targetAccuracy,
        'targetMet': targetMet,
        'speedScore': speedScore,
        'seconds': seconds.round(),
        'editDistance': distance,
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Typing Result — $skillScore%'),
        content: Text(
          'Accuracy: $accuracy% (Target $_targetAccuracy%)\n'
          'Speed: $wpm WPM (Target $_targetWpm WPM)\n'
          'Errors: $distance\n\n'
          '${targetMet ? 'Target achieved.' : 'Target পূরণ করতে accuracy ও speed দুটোই আরও practice করুন।'}',
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
      appBar: AppBar(title: const Text('Typing Lab')),
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
          Text('Target: $_targetWpm WPM • $_targetAccuracy% Accuracy'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(
                _target,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            minLines: 5,
            maxLines: 10,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'এখানে টাইপ করুন',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.speed_rounded),
          label: const Text('Result দেখুন'),
        ),
      ),
    );
  }
}
