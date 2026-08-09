import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';
import '../services/word_practical_evaluator.dart';

enum _EditingBlock { heading, paragraph }

class _BlockFormat {
  bool bold = false;
  bool italic = false;
  bool underline = false;
  double fontSize;
  TextAlign alignment = TextAlign.left;

  _BlockFormat({required this.fontSize});
}

class WordLabScreen extends StatefulWidget {
  const WordLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WordLabScreen> createState() => _WordLabScreenState();
}

class _WordLabScreenState extends State<WordLabScreen> {
  final _headingController = TextEditingController();
  final _paragraphController = TextEditingController();
  final _headingFocus = FocusNode();
  final _paragraphFocus = FocusNode();
  final _evaluator = const WordPracticalEvaluator();

  final _headingFormat = _BlockFormat(fontSize: 14);
  final _paragraphFormat = _BlockFormat(fontSize: 12);
  _EditingBlock _editingBlock = _EditingBlock.heading;
  List<List<TextEditingController>> _tableControllers = [];
  bool _submitting = false;

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  String get _instruction =>
      widget.lesson.practicalData['instruction'] as String? ??
      'নির্দেশনা অনুযায়ী document তৈরি করুন।';

  @override
  void initState() {
    super.initState();
    _headingController.text = widget.lesson.practicalData['starterHeading'] as String? ?? '';
    _paragraphController.text = widget.lesson.practicalData['starterParagraph'] as String? ?? '';
    _headingFocus.addListener(() {
      if (_headingFocus.hasFocus && mounted) {
        setState(() => _editingBlock = _EditingBlock.heading);
      }
    });
    _paragraphFocus.addListener(() {
      if (_paragraphFocus.hasFocus && mounted) {
        setState(() => _editingBlock = _EditingBlock.paragraph);
      }
    });
  }

  @override
  void dispose() {
    _headingController.dispose();
    _paragraphController.dispose();
    _headingFocus.dispose();
    _paragraphFocus.dispose();
    _disposeTable();
    super.dispose();
  }

  void _disposeTable() {
    for (final row in _tableControllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    _tableControllers = [];
  }

  _BlockFormat get _activeFormat =>
      _editingBlock == _EditingBlock.heading ? _headingFormat : _paragraphFormat;

  TextStyle _styleFor(_BlockFormat format) {
    return TextStyle(
      fontSize: format.fontSize,
      height: 1.45,
      fontWeight: format.bold ? FontWeight.bold : FontWeight.normal,
      fontStyle: format.italic ? FontStyle.italic : FontStyle.normal,
      decoration: format.underline ? TextDecoration.underline : TextDecoration.none,
    );
  }

  String _alignmentKey(TextAlign alignment) {
    switch (alignment) {
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
      case TextAlign.end:
        return 'right';
      case TextAlign.justify:
        return 'justify';
      case TextAlign.left:
      case TextAlign.start:
        return 'left';
    }
  }

  IconData _alignmentIcon(TextAlign alignment) {
    switch (alignment) {
      case TextAlign.center:
        return Icons.format_align_center_rounded;
      case TextAlign.right:
      case TextAlign.end:
        return Icons.format_align_right_rounded;
      case TextAlign.justify:
        return Icons.format_align_justify_rounded;
      case TextAlign.left:
      case TextAlign.start:
        return Icons.format_align_left_rounded;
    }
  }

  void _toggleBold() => setState(() => _activeFormat.bold = !_activeFormat.bold);
  void _toggleItalic() => setState(() => _activeFormat.italic = !_activeFormat.italic);
  void _toggleUnderline() =>
      setState(() => _activeFormat.underline = !_activeFormat.underline);

  void _setFontSize(double value) => setState(() => _activeFormat.fontSize = value);
  void _setAlignment(TextAlign value) => setState(() => _activeFormat.alignment = value);

  Future<void> _insertTable() async {
    var rows = 3;
    var columns = 3;
    final result = await showDialog<(int, int)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Table Insert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Rows')),
                  DropdownButton<int>(
                    value: rows,
                    items: [for (var i = 1; i <= 6; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => rows = value);
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Expanded(child: Text('Columns')),
                  DropdownButton<int>(
                    value: columns,
                    items: [for (var i = 1; i <= 6; i++) DropdownMenuItem(value: i, child: Text('$i'))],
                    onChanged: (value) {
                      if (value != null) setDialogState(() => columns = value);
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop((rows, columns)),
              child: const Text('Insert'),
            ),
          ],
        ),
      ),
    );

    if (result == null || !mounted) return;
    _disposeTable();
    setState(() {
      _tableControllers = List.generate(
        result.$1,
        (_) => List.generate(result.$2, (_) => TextEditingController()),
      );
    });
  }

  void _clearDocument() {
    _disposeTable();
    setState(() {
      _headingController.clear();
      _paragraphController.clear();
      _headingFormat
        ..bold = false
        ..italic = false
        ..underline = false
        ..fontSize = 14
        ..alignment = TextAlign.left;
      _paragraphFormat
        ..bold = false
        ..italic = false
        ..underline = false
        ..fontSize = 12
        ..alignment = TextAlign.left;
      _editingBlock = _EditingBlock.heading;
    });
  }

  List<List<String>> _tableValues() {
    return [
      for (final row in _tableControllers)
        [for (final controller in row) controller.text],
    ];
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final result = _evaluator.evaluate(
      task: _task,
      submission: WordPracticalSubmission(
        headingText: _headingController.text,
        paragraphText: _paragraphController.text,
        headingBold: _headingFormat.bold,
        headingItalic: _headingFormat.italic,
        headingUnderline: _headingFormat.underline,
        headingFontSize: _headingFormat.fontSize,
        headingAlignment: _alignmentKey(_headingFormat.alignment),
        paragraphBold: _paragraphFormat.bold,
        paragraphItalic: _paragraphFormat.italic,
        paragraphUnderline: _paragraphFormat.underline,
        paragraphFontSize: _paragraphFormat.fontSize,
        paragraphAlignment: _alignmentKey(_paragraphFormat.alignment),
        tableValues: _tableValues(),
      ),
    );

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'word_formatting',
      score: result.score,
      metrics: {
        'passedChecks': result.checks.where((check) => check.passed).length,
        'totalChecks': result.checks.length,
        'checks': [
          for (final check in result.checks)
            {'label': check.label, 'passed': check.passed},
        ],
        'tableRows': _tableControllers.length,
        'tableColumns': _tableControllers.isEmpty ? 0 : _tableControllers.first.length,
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Word Practical — ${result.score}%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                result.score >= 80
                    ? 'দারুণ। মূল task-গুলো সঠিকভাবে সম্পন্ন হয়েছে।'
                    : 'যে task-গুলো ভুল হয়েছে সেগুলো দেখে আবার practice করুন।',
              ),
              const SizedBox(height: 14),
              for (final check in result.checks)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    check.passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: check.passed ? Colors.green : Theme.of(context).colorScheme.error,
                  ),
                  title: Text(check.label),
                ),
            ],
          ),
        ),
        actions: [
          if (result.score < 100)
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

  Widget _toolButton({
    required IconData icon,
    required String tooltip,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      isSelected: selected,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  Widget _buildToolbar() {
    final format = _activeFormat;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
            child: Row(
              children: [
                SegmentedButton<_EditingBlock>(
                  segments: const [
                    ButtonSegment(value: _EditingBlock.heading, label: Text('Heading')),
                    ButtonSegment(value: _EditingBlock.paragraph, label: Text('Paragraph')),
                  ],
                  selected: {_editingBlock},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) {
                    setState(() => _editingBlock = value.first);
                    if (value.first == _EditingBlock.heading) {
                      _headingFocus.requestFocus();
                    } else {
                      _paragraphFocus.requestFocus();
                    }
                  },
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Document clear',
                  onPressed: _clearDocument,
                  icon: const Icon(Icons.restart_alt_rounded),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
            child: Row(
              children: [
                _toolButton(
                  icon: Icons.format_bold_rounded,
                  tooltip: 'Bold',
                  selected: format.bold,
                  onPressed: _toggleBold,
                ),
                _toolButton(
                  icon: Icons.format_italic_rounded,
                  tooltip: 'Italic',
                  selected: format.italic,
                  onPressed: _toggleItalic,
                ),
                _toolButton(
                  icon: Icons.format_underlined_rounded,
                  tooltip: 'Underline',
                  selected: format.underline,
                  onPressed: _toggleUnderline,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: format.fontSize,
                      items: const [10, 11, 12, 14, 16, 18, 20, 24]
                          .map((size) => DropdownMenuItem<double>(
                                value: size.toDouble(),
                                child: Text('$size pt'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _setFontSize(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<TextAlign>(
                  tooltip: 'Alignment',
                  initialValue: format.alignment,
                  onSelected: _setAlignment,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: TextAlign.left, child: Text('Left')),
                    PopupMenuItem(value: TextAlign.center, child: Text('Center')),
                    PopupMenuItem(value: TextAlign.right, child: Text('Right')),
                    PopupMenuItem(value: TextAlign.justify, child: Text('Justify')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(_alignmentIcon(format.alignment)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _insertTable,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Table'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCanvas() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
      constraints: const BoxConstraints(minHeight: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 8),
            color: Color(0x18000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _headingController,
            focusNode: _headingFocus,
            textAlign: _headingFormat.alignment,
            style: _styleFor(_headingFormat),
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration.collapsed(hintText: 'Heading লিখুন'),
          ),
          const SizedBox(height: 22),
          TextField(
            controller: _paragraphController,
            focusNode: _paragraphFocus,
            textAlign: _paragraphFormat.alignment,
            style: _styleFor(_paragraphFormat),
            minLines: 5,
            maxLines: 12,
            decoration: const InputDecoration.collapsed(hintText: 'Paragraph লিখুন'),
          ),
          if (_tableControllers.isNotEmpty) ...[
            const SizedBox(height: 24),
            Table(
              border: TableBorder.all(color: Colors.black54),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: [
                for (final row in _tableControllers)
                  TableRow(
                    children: [
                      for (final controller in row)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: TextField(
                            controller: controller,
                            minLines: 1,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MS Word Practical Lab'),
            Text('Offline Simulator', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.practicalData['taskTitle'] as String? ?? 'Practice Task',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(_instruction),
              ],
            ),
          ),
          _buildToolbar(),
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildDocumentCanvas(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(14),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Task যাচাই করুন'),
        ),
      ),
    );
  }
}
