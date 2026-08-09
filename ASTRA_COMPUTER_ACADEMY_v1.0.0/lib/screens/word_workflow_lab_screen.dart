import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class WordWorkflowLabScreen extends StatefulWidget {
  const WordWorkflowLabScreen({super.key, required this.lesson, required this.progressRepository});
  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WordWorkflowLabScreen> createState() => _WordWorkflowLabScreenState();
}

class _WordWorkflowLabScreenState extends State<WordWorkflowLabScreen> {
  final _filename = TextEditingController();
  String _format = 'DOCX';
  String _orientation = 'Portrait';
  String _margins = 'Normal';
  int _copies = 1;
  bool _saved = false;
  bool _printPreviewOpened = false;

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  @override
  void initState() {
    super.initState();
    _filename.text = widget.lesson.practicalData['starterFilename'] as String? ?? '';
  }

  @override
  void dispose() {
    _filename.dispose();
    super.dispose();
  }

  List<(String, bool)> _checks() {
    final checks = <(String, bool)>[];
    if (_task['filename'] != null) {
      checks.add(('Filename: ${_task['filename']}', _filename.text.trim() == _task['filename']));
    }
    if (_task['format'] != null) checks.add(('Format: ${_task['format']}', _format == _task['format']));
    if (_task['orientation'] != null) {
      checks.add(('Orientation: ${_task['orientation']}', _orientation == _task['orientation']));
    }
    if (_task['margins'] != null) checks.add(('Margins: ${_task['margins']}', _margins == _task['margins']));
    if (_task['copies'] != null) checks.add(('Print copies: ${_task['copies']}', _copies == _task['copies']));
    if (_task['requireSave'] == true) checks.add(('Save As সম্পন্ন', _saved));
    if (_task['requirePrintPreview'] == true) checks.add(('Print Preview খোলা', _printPreviewOpened));
    return checks;
  }

  Future<void> _submit() async {
    final checks = _checks();
    final passed = checks.where((e) => e.$2).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'word_workflow',
      score: score,
      metrics: {
        'filename': _filename.text,
        'format': _format,
        'orientation': _orientation,
        'margins': _margins,
        'copies': _copies,
        'saved': _saved,
        'printPreview': _printPreviewOpened,
      },
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Word Workflow — $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in checks)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.$2 ? Icons.check_circle : Icons.cancel),
                title: Text(item.$1),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Edit')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Word Save / Print Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Text(
            widget.lesson.practicalData['instruction'] as String? ?? 'নির্দেশনা অনুযায়ী page setup, save ও print করুন।',
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _filename,
            decoration: const InputDecoration(labelText: 'File name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          _choice('Save format', _format, const ['DOCX', 'PDF'], (v) => setState(() => _format = v)),
          _choice('Orientation', _orientation, const ['Portrait', 'Landscape'], (v) => setState(() => _orientation = v)),
          _choice('Margins', _margins, const ['Normal', 'Narrow', 'Wide'], (v) => setState(() => _margins = v)),
          Card(
            child: ListTile(
              title: const Text('Print copies'),
              subtitle: Text('$_copies'),
              trailing: Wrap(
                children: [
                  IconButton(onPressed: _copies > 1 ? () => setState(() => _copies--) : null, icon: const Icon(Icons.remove)),
                  IconButton(onPressed: () => setState(() => _copies++), icon: const Icon(Icons.add)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _saved = true),
                  icon: Icon(_saved ? Icons.check_circle : Icons.save_outlined),
                  label: Text(_saved ? 'Saved' : 'Save As'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _printPreviewOpened = true),
                  icon: Icon(_printPreviewOpened ? Icons.check_circle : Icons.print_outlined),
                  label: const Text('Print Preview'),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Workflow যাচাই করুন'),
        ),
      ),
    );
  }

  Widget _choice(String title, String value, List<String> values, ValueChanged<String> onChanged) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: DropdownButton<String>(
          value: value,
          items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
