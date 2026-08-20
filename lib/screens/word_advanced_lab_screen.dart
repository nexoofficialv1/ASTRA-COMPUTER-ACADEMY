import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class WordAdvancedLabScreen extends StatefulWidget {
  const WordAdvancedLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WordAdvancedLabScreen> createState() => _WordAdvancedLabScreenState();
}

class _WordAdvancedLabScreenState extends State<WordAdvancedLabScreen> {
  final _document = TextEditingController();
  final _find = TextEditingController();
  final _replace = TextEditingController();
  final _wordArt = TextEditingController();

  bool _spellChecked = false;
  bool _thesaurusUsed = false;
  bool _replaced = false;
  bool _bold = false;
  bool _center = false;
  bool _numberedList = false;
  bool _pictureInserted = false;
  bool _drawingUsed = false;
  bool _saved = false;
  int _fontSize = 12;
  String _orientation = 'Portrait';
  String _wrap = 'In Line';

  List<Map<String, dynamic>> get _requirements =>
      (widget.lesson.practicalData['requirements'] as List<dynamic>? ??
              const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  @override
  void initState() {
    super.initState();
    _document.text =
        widget.lesson.practicalData['starterText'] as String? ?? '';
    _find.text = widget.lesson.practicalData['findText'] as String? ?? '';
    _replace.text =
        widget.lesson.practicalData['replaceText'] as String? ?? '';
  }

  @override
  void dispose() {
    _document.dispose();
    _find.dispose();
    _replace.dispose();
    _wordArt.dispose();
    super.dispose();
  }

  void _findReplace() {
    final findText = _find.text;
    if (findText.isEmpty) return;
    setState(() {
      _document.text =
          _document.text.replaceAll(findText, _replace.text);
      _replaced = true;
    });
  }

  void _proofread() {
    setState(() {
      _document.text = _document.text
          .replaceAll('quik', 'quick')
          .replaceAll('teh', 'the');
      _spellChecked = true;
    });
  }

  void _thesaurus() {
    setState(() => _thesaurusUsed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thesaurus suggestion: quick → fast / rapid'),
      ),
    );
  }

  bool _check(Map<String, dynamic> requirement) {
    final type = requirement['type'] as String? ?? '';
    switch (type) {
      case 'find_replace':
        return _replaced &&
            _document.text.contains(
              requirement['replacement'] as String? ?? _replace.text,
            );
      case 'spell_check':
        return _spellChecked;
      case 'thesaurus':
        return _thesaurusUsed;
      case 'bold':
        return _bold;
      case 'center':
        return _center;
      case 'font_size':
        return _fontSize >=
            ((requirement['value'] as num?)?.toInt() ?? 16);
      case 'numbered_list':
        return _numberedList;
      case 'orientation':
        return _orientation == requirement['value'];
      case 'insert_picture':
        return _pictureInserted;
      case 'text_wrap':
        return _wrap == requirement['value'];
      case 'draw':
        return _drawingUsed;
      case 'wordart':
        return _wordArt.text.trim().length >= 3;
      case 'save':
        return _saved;
      default:
        return false;
    }
  }

  String _label(Map<String, dynamic> requirement) {
    switch (requirement['type']) {
      case 'find_replace':
        return 'Find & Replace সম্পন্ন';
      case 'spell_check':
        return 'Spelling/Grammar check';
      case 'thesaurus':
        return 'Thesaurus ব্যবহার';
      case 'bold':
        return 'Bold formatting';
      case 'center':
        return 'Center alignment';
      case 'font_size':
        return 'Font size ≥ ${requirement['value']}';
      case 'numbered_list':
        return 'Numbered list';
      case 'orientation':
        return 'Orientation: ${requirement['value']}';
      case 'insert_picture':
        return 'Picture insert';
      case 'text_wrap':
        return 'Text Wrapping: ${requirement['value']}';
      case 'draw':
        return 'Draw tool ব্যবহার';
      case 'wordart':
        return 'WordArt title';
      case 'save':
        return 'Document Save';
      default:
        return requirement['type'] as String? ?? 'Task';
    }
  }

  Future<void> _evaluate() async {
    final checks = [for (final item in _requirements) _check(item)];
    final passed = checks.where((value) => value).length;
    final score =
        checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'word_advanced',
      score: score,
      metrics: {
        'mode': widget.lesson.practicalData['mode'],
        'spellChecked': _spellChecked,
        'thesaurusUsed': _thesaurusUsed,
        'findReplace': _replaced,
        'bold': _bold,
        'center': _center,
        'fontSize': _fontSize,
        'numberedList': _numberedList,
        'orientation': _orientation,
        'pictureInserted': _pictureInserted,
        'textWrap': _wrap,
        'drawingUsed': _drawingUsed,
        'wordArt': _wordArt.text.trim(),
        'saved': _saved,
      },
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Word Advanced Practical — $score%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < _requirements.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    checks[i]
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                  ),
                  title: Text(_label(_requirements[i])),
                ),
            ],
          ),
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
            'Word-এর advanced tools ব্যবহার করে task সম্পন্ন করুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Word 2019 Advanced Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _document,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Document',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Editing & Proofing',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _find,
                          decoration:
                              const InputDecoration(labelText: 'Find'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _replace,
                          decoration:
                              const InputDecoration(labelText: 'Replace'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _findReplace,
                        icon: const Icon(Icons.find_replace_rounded),
                        label: const Text('Replace All'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _proofread,
                        icon: const Icon(Icons.spellcheck_rounded),
                        label: Text(
                          _spellChecked ? 'Proofread ✓' : 'Spelling Check',
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: _thesaurus,
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(
                          _thesaurusUsed ? 'Thesaurus ✓' : 'Thesaurus',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formatting',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Bold'),
                        selected: _bold,
                        onSelected: (value) => setState(() => _bold = value),
                      ),
                      FilterChip(
                        label: const Text('Center'),
                        selected: _center,
                        onSelected: (value) =>
                            setState(() => _center = value),
                      ),
                      FilterChip(
                        label: const Text('Numbered List'),
                        selected: _numberedList,
                        onSelected: (value) =>
                            setState(() => _numberedList = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Text('Font Size')),
                      DropdownButton<int>(
                        value: _fontSize,
                        items: [12, 14, 16, 18, 20, 24]
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value pt'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _fontSize = value);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(child: Text('Page Orientation')),
                      DropdownButton<String>(
                        value: _orientation,
                        items: ['Portrait', 'Landscape']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _orientation = value);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Graphics, Draw & WordArt',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Insert Picture'),
                        avatar: const Icon(Icons.image_rounded),
                        selected: _pictureInserted,
                        onSelected: (value) =>
                            setState(() => _pictureInserted = value),
                      ),
                      FilterChip(
                        label: const Text('Draw'),
                        avatar: const Icon(Icons.draw_rounded),
                        selected: _drawingUsed,
                        onSelected: (value) =>
                            setState(() => _drawingUsed = value),
                      ),
                      FilterChip(
                        label: const Text('Save'),
                        avatar: const Icon(Icons.save_rounded),
                        selected: _saved,
                        onSelected: (value) =>
                            setState(() => _saved = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Text('Text Wrapping')),
                      DropdownButton<String>(
                        value: _wrap,
                        items: ['In Line', 'Square', 'Tight', 'Behind Text']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _wrap = value);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _wordArt,
                    decoration: const InputDecoration(
                      labelText: 'WordArt text',
                      hintText: 'COMPUTER CLUB',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Required tasks',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  for (final item in _requirements)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          Icon(
                            _check(item)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_label(item))),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _evaluate,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Word Task Evaluate করুন'),
        ),
      ),
    );
  }
}
