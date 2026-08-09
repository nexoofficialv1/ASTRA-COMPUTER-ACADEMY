import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class _SlideDraft {
  _SlideDraft({this.title = '', this.body = '', this.bullets = false});
  String title;
  String body;
  bool bullets;
}

class PowerPointLabScreen extends StatefulWidget {
  const PowerPointLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<PowerPointLabScreen> createState() => _PowerPointLabScreenState();
}

class _PowerPointLabScreenState extends State<PowerPointLabScreen> {
  final List<_SlideDraft> _slides = [_SlideDraft()];
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _selected = 0;
  String _theme = 'Light';

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  @override
  void initState() {
    super.initState();
    final starter = widget.lesson.practicalData['starterSlides'] as List<dynamic>?;
    if (starter != null && starter.isNotEmpty) {
      _slides.clear();
      for (final raw in starter) {
        final item = Map<String, dynamic>.from(raw as Map);
        _slides.add(_SlideDraft(
          title: item['title'] as String? ?? '',
          body: item['body'] as String? ?? '',
          bullets: item['bullets'] == true,
        ));
      }
    }
    _theme = widget.lesson.practicalData['starterTheme'] as String? ?? 'Light';
    _loadSelected();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveSelected() {
    final slide = _slides[_selected];
    slide.title = _titleController.text;
    slide.body = _bodyController.text;
  }

  void _loadSelected() {
    final slide = _slides[_selected];
    _titleController.text = slide.title;
    _bodyController.text = slide.body;
  }

  void _selectSlide(int index) {
    _saveSelected();
    setState(() {
      _selected = index;
      _loadSelected();
    });
  }

  void _addSlide() {
    _saveSelected();
    setState(() {
      _slides.add(_SlideDraft());
      _selected = _slides.length - 1;
      _loadSelected();
    });
  }

  void _deleteSlide() {
    if (_slides.length == 1) return;
    setState(() {
      _slides.removeAt(_selected);
      if (_selected >= _slides.length) _selected = _slides.length - 1;
      _loadSelected();
    });
  }

  bool _contains(String source, Object? expected) =>
      source.toLowerCase().contains(expected?.toString().trim().toLowerCase() ?? '');

  List<(String, bool)> _evaluate() {
    _saveSelected();
    final checks = <(String, bool)>[];
    final minSlides = _task['minSlides'] as int?;
    if (minSlides != null) checks.add(('কমপক্ষে $minSlidesটি slide', _slides.length >= minSlides));
    final expectedTheme = _task['theme'] as String?;
    if (expectedTheme != null) checks.add(('Theme: $expectedTheme', _theme == expectedTheme));

    for (final raw in _task['slideChecks'] as List<dynamic>? ?? const []) {
      final item = Map<String, dynamic>.from(raw as Map);
      final index = (item['slide'] as int? ?? 1) - 1;
      final exists = index >= 0 && index < _slides.length;
      final slide = exists ? _slides[index] : _SlideDraft();
      if (item['titleContains'] != null) {
        checks.add(('Slide ${index + 1} title', exists && _contains(slide.title, item['titleContains'])));
      }
      if (item['bodyContains'] != null) {
        checks.add(('Slide ${index + 1} content', exists && _contains(slide.body, item['bodyContains'])));
      }
      if (item['bullets'] != null) {
        checks.add(('Slide ${index + 1} bullet list', exists && slide.bullets == item['bullets']));
      }
    }
    return checks;
  }

  Future<void> _submit() async {
    final checks = _evaluate();
    final passed = checks.where((item) => item.$2).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'powerpoint',
      score: score,
      metrics: {
        'slides': _slides.length,
        'theme': _theme,
        'passedChecks': passed,
        'totalChecks': checks.length,
      },
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PowerPoint Practical — $score%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
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
    final slide = _slides[_selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerPoint Practical Lab'),
        actions: [
          IconButton(onPressed: _addSlide, tooltip: 'New Slide', icon: const Icon(Icons.add_box_outlined)),
          IconButton(onPressed: _deleteSlide, tooltip: 'Delete Slide', icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.lesson.practicalData['instruction'] as String? ?? 'নির্দেশনা অনুযায়ী presentation তৈরি করুন।',
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _slides.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ChoiceChip(
                label: Text('Slide ${index + 1}'),
                selected: index == _selected,
                onSelected: (_) => _selectSlide(index),
              ),
            ),
          ),
          Row(
            children: [
              const Text('Theme: '),
              DropdownButton<String>(
                value: _theme,
                items: const ['Light', 'Dark', 'Professional']
                    .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (value) => setState(() => _theme = value ?? _theme),
              ),
              const Spacer(),
              FilterChip(
                selected: slide.bullets,
                label: const Text('Bullets'),
                avatar: const Icon(Icons.format_list_bulleted, size: 18),
                onSelected: (value) => setState(() => slide.bullets = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            constraints: const BoxConstraints(minHeight: 330),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
            ),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: 'Click to add title', border: InputBorder.none),
                ),
                const Divider(),
                SizedBox(
                  height: 210,
                  child: TextField(
                    controller: _bodyController,
                    maxLines: 9,
                    style: const TextStyle(fontSize: 17, height: 1.5),
                    decoration: InputDecoration(
                      hintText: slide.bullets ? '• First point\n• Second point' : 'Click to add content',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.fact_check_outlined),
          label: const Text('Presentation যাচাই করুন'),
        ),
      ),
    );
  }
}
