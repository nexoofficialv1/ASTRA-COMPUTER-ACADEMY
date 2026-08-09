import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class WordPageElementsLabScreen extends StatefulWidget {
  const WordPageElementsLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WordPageElementsLabScreen> createState() => _WordPageElementsLabScreenState();
}

class _WordPageElementsLabScreenState extends State<WordPageElementsLabScreen> {
  final _headerController = TextEditingController();
  final _footerController = TextEditingController();
  String _pageNumberPosition = 'None';
  bool _differentFirstPage = false;
  bool _submitting = false;

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  bool _textMatches(String value, Object? expected) =>
      value.trim().toLowerCase() == expected?.toString().trim().toLowerCase();

  List<(String, bool)> _checks() {
    final checks = <(String, bool)>[];
    if (_task['header'] != null) {
      checks.add(('Header: ${_task['header']}', _textMatches(_headerController.text, _task['header'])));
    }
    if (_task['footer'] != null) {
      checks.add(('Footer: ${_task['footer']}', _textMatches(_footerController.text, _task['footer'])));
    }
    if (_task['pageNumberPosition'] != null) {
      checks.add((
        'Page Number: ${_task['pageNumberPosition']}',
        _pageNumberPosition == _task['pageNumberPosition'],
      ));
    }
    if (_task['differentFirstPage'] != null) {
      checks.add((
        'Different First Page: ${_task['differentFirstPage'] == true ? 'On' : 'Off'}',
        _differentFirstPage == (_task['differentFirstPage'] == true),
      ));
    }
    return checks;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final checks = _checks();
    final passed = checks.where((item) => item.$2).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();
    setState(() => _submitting = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'word_page_elements',
      score: score,
      metrics: {
        'header': _headerController.text.trim(),
        'footer': _footerController.text.trim(),
        'pageNumberPosition': _pageNumberPosition,
        'differentFirstPage': _differentFirstPage,
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Word Page Elements — $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in checks)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(item.$2 ? Icons.check_circle_rounded : Icons.cancel_rounded),
                title: Text(item.$1),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Edit')),
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
    final instruction = widget.lesson.practicalData['instruction'] as String? ??
        'Header, Footer ও Page Number সেট করুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Word Header / Footer Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Text(instruction, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _headerController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Header',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 28),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sample document body\n\nThis area represents the main page content.',
                    style: TextStyle(height: 1.6),
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _footerController,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Footer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Page number preview: ${_pageNumberPosition == 'None' ? '—' : '1'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Page Number Position'),
              trailing: DropdownButton<String>(
                value: _pageNumberPosition,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None')),
                  DropdownMenuItem(value: 'Top Center', child: Text('Top Center')),
                  DropdownMenuItem(value: 'Top Right', child: Text('Top Right')),
                  DropdownMenuItem(value: 'Bottom Center', child: Text('Bottom Center')),
                  DropdownMenuItem(value: 'Bottom Right', child: Text('Bottom Right')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _pageNumberPosition = value);
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Different First Page'),
            subtitle: const Text('প্রথম পেজে আলাদা header/footer ব্যবহার করার setting।'),
            value: _differentFirstPage,
            onChanged: (value) => setState(() => _differentFirstPage = value),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Page setup যাচাই করুন'),
        ),
      ),
    );
  }
}
