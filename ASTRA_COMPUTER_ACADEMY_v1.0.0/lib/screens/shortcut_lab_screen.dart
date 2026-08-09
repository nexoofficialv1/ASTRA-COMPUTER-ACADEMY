import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class ShortcutLabScreen extends StatefulWidget {
  const ShortcutLabScreen({super.key, required this.lesson, required this.progressRepository});
  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<ShortcutLabScreen> createState() => _ShortcutLabScreenState();
}

class _ShortcutLabScreenState extends State<ShortcutLabScreen> {
  bool _ctrl = false;
  bool _alt = false;
  bool _shift = false;
  final List<String> _entered = [];

  List<String> get _expected => (widget.lesson.practicalData['expected'] as List<dynamic>? ?? const [])
      .map((item) => item.toString().toUpperCase())
      .toList();

  void _key(String key) {
    final parts = <String>[];
    if (_ctrl) parts.add('CTRL');
    if (_alt) parts.add('ALT');
    if (_shift) parts.add('SHIFT');
    parts.add(key.toUpperCase());
    setState(() {
      _entered.add(parts.join('+'));
      _ctrl = false;
      _alt = false;
      _shift = false;
    });
  }

  Future<void> _submit() async {
    var passed = 0;
    for (var i = 0; i < _expected.length; i++) {
      if (i < _entered.length && _entered[i] == _expected[i]) passed++;
    }
    final score = _expected.isEmpty ? 100 : ((passed / _expected.length) * 100).round();
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'keyboard_shortcuts',
      score: score,
      metrics: {'expected': _expected, 'entered': _entered, 'passed': passed},
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shortcut Practice — $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _expected.length; i++)
              ListTile(
                dense: true,
                leading: Icon(i < _entered.length && _entered[i] == _expected[i]
                    ? Icons.check_circle
                    : Icons.cancel),
                title: Text(_expected[i]),
                subtitle: Text(i < _entered.length ? 'আপনি: ${_entered[i]}' : 'আপনি: —'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(_entered.clear);
            },
            child: const Text('আবার'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('শেষ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const letters = ['A', 'C', 'V', 'X', 'S', 'P', 'Z', 'Y', 'F', 'TAB'];
    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Shortcut Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Text(
            widget.lesson.practicalData['instruction'] as String? ?? 'Virtual keyboard দিয়ে shortcut দিন।',
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _expected.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text((widget.lesson.practicalData['prompts'] as List<dynamic>? ?? const [])
                        .elementAtOrNull(i)
                        ?.toString() ??
                    _expected[i]),
                trailing: Text(i < _entered.length ? _entered[i] : '—'),
              ),
            ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(label: const Text('Ctrl'), selected: _ctrl, onSelected: (v) => setState(() => _ctrl = v)),
              FilterChip(label: const Text('Alt'), selected: _alt, onSelected: (v) => setState(() => _alt = v)),
              FilterChip(label: const Text('Shift'), selected: _shift, onSelected: (v) => setState(() => _shift = v)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final key in letters)
                SizedBox(
                  width: key == 'TAB' ? 92 : 64,
                  child: OutlinedButton(onPressed: () => _key(key), child: Text(key)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => setState(_entered.clear),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset sequence'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Shortcut যাচাই করুন'),
        ),
      ),
    );
  }
}

extension _SafeElementAt<T> on List<T> {
  T? elementAtOrNull(int index) => index < 0 || index >= length ? null : this[index];
}
