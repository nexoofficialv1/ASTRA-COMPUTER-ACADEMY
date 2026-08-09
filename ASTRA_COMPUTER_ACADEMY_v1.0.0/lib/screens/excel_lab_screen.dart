import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/excel_formula_engine.dart';
import '../services/excel_practical_evaluator.dart';
import '../services/progress_repository.dart';

class ExcelLabScreen extends StatefulWidget {
  const ExcelLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<ExcelLabScreen> createState() => _ExcelLabScreenState();
}

class _ExcelLabScreenState extends State<ExcelLabScreen> {
  final _engine = const ExcelFormulaEngine();
  final _evaluator = const ExcelPracticalEvaluator();
  final _formulaController = TextEditingController();
  final Map<String, String> _cells = {};
  String _selectedCell = 'A1';
  bool _submitting = false;

  int get _rows => widget.lesson.practicalData['rows'] as int? ?? 8;
  int get _columns => widget.lesson.practicalData['columns'] as int? ?? 6;

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  Set<String> get _lockedCells {
    final configured = widget.lesson.practicalData['lockedCells'] as List<dynamic>?;
    if (configured != null) {
      return configured.map((item) => item.toString().toUpperCase()).toSet();
    }
    final initial = widget.lesson.practicalData['initialCells'] as Map<String, dynamic>? ?? const {};
    return initial.keys.map((key) => key.toUpperCase()).toSet();
  }

  String get _instruction => widget.lesson.practicalData['instruction'] as String? ??
      'নির্দেশনা অনুযায়ী worksheet সম্পন্ন করুন।';

  @override
  void initState() {
    super.initState();
    final initial = Map<String, dynamic>.from(
      widget.lesson.practicalData['initialCells'] as Map<String, dynamic>? ?? const {},
    );
    for (final entry in initial.entries) {
      _cells[entry.key.toUpperCase()] = entry.value.toString();
    }
    _selectedCell = widget.lesson.practicalData['startCell'] as String? ?? _firstEditableCell();
    _formulaController.text = _cells[_selectedCell] ?? '';
  }

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }

  String _firstEditableCell() {
    for (var row = 1; row <= _rows; row++) {
      for (var column = 1; column <= _columns; column++) {
        final ref = '${_columnName(column)}$row';
        if (!_lockedCells.contains(ref)) return ref;
      }
    }
    return 'A1';
  }

  String _columnName(int column) {
    var current = column;
    final chars = <int>[];
    while (current > 0) {
      current--;
      chars.add(65 + (current % 26));
      current ~/= 26;
    }
    return String.fromCharCodes(chars.reversed);
  }

  void _selectCell(String reference) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedCell = reference;
      _formulaController.text = _cells[reference] ?? '';
      _formulaController.selection = TextSelection.collapsed(offset: _formulaController.text.length);
    });
  }

  void _applyFormulaBar() {
    if (_lockedCells.contains(_selectedCell)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই cell-টি source data, তাই edit করা যাবে না।')),
      );
      return;
    }
    setState(() {
      final value = _formulaController.text;
      if (value.trim().isEmpty) {
        _cells.remove(_selectedCell);
      } else {
        _cells[_selectedCell] = value;
      }
    });
  }

  void _clearEditableCells() {
    setState(() {
      _cells.removeWhere((key, _) => !_lockedCells.contains(key));
      _selectedCell = _firstEditableCell();
      _formulaController.text = _cells[_selectedCell] ?? '';
    });
  }

  String _displayValue(String reference) {
    final raw = _cells[reference] ?? '';
    if (raw.trim().isEmpty) return '';
    if (!raw.trim().startsWith('=')) return raw;
    return _engine.evaluateCell(reference, _cells).display;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    _applyFormulaBar();
    setState(() => _submitting = true);

    final result = _evaluator.evaluate(task: _task, cells: _cells);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'excel_formula',
      score: result.score,
      metrics: {
        'passedChecks': result.checks.where((check) => check.passed).length,
        'totalChecks': result.checks.length,
        'checks': [
          for (final check in result.checks)
            {'label': check.label, 'passed': check.passed},
        ],
        'filledCells': _cells.entries.where((entry) => entry.value.trim().isNotEmpty).length,
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Excel Practical — ${result.score}%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                result.score >= 80
                    ? 'ভালো হয়েছে। Result এবং formula দুটোই যাচাই করা হয়েছে।'
                    : 'ভুল check-গুলো দেখে worksheet-এ ফিরে আবার চেষ্টা করুন।',
              ),
              const SizedBox(height: 12),
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

  Widget _buildCell(String reference) {
    final selected = reference == _selectedCell;
    final locked = _lockedCells.contains(reference);
    final value = _displayValue(reference);
    final raw = _cells[reference] ?? '';
    final isFormula = raw.trim().startsWith('=');
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _selectCell(reference),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 92,
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer
              : locked
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surface,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: locked ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (isFormula)
              Icon(Icons.functions_rounded, size: 12, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
              ),
              for (var column = 1; column <= _columns; column++)
                Container(
                  width: 92,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text(
                    _columnName(column),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          for (var row = 1; row <= _rows; row++)
            Row(
              children: [
                Container(
                  width: 42,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Text('$row', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
                for (var column = 1; column <= _columns; column++)
                  _buildCell('${_columnName(column)}$row'),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLocked = _lockedCells.contains(_selectedCell);
    final selectedEvaluation = _engine.evaluateCell(_selectedCell, _cells);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Practical Lab'),
        actions: [
          IconButton(
            onPressed: _clearEditableCells,
            tooltip: 'Reset',
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.practicalData['taskTitle'] as String? ?? 'Excel Task',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(_instruction, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 64,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                ),
                child: Text(_selectedCell, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Expanded(
                child: TextField(
                  controller: _formulaController,
                  readOnly: selectedLocked,
                  onSubmitted: (_) => _applyFormulaBar(),
                  decoration: InputDecoration(
                    hintText: selectedLocked ? 'Source cell' : '=B2+C2 বা value লিখুন',
                    prefixIcon: const Icon(Icons.functions_rounded),
                    suffixIcon: IconButton(
                      onPressed: selectedLocked ? null : _applyFormulaBar,
                      icon: const Icon(Icons.check_rounded),
                      tooltip: 'Apply',
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedLocked
                ? '$_selectedCell source data — read only'
                : 'Result: ${selectedEvaluation.display.isEmpty ? '—' : selectedEvaluation.display}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          _buildGrid(),
          const SizedBox(height: 14),
          const Text(
            'Formula Help: =B2+C2  •  =SUM(B2:B5)  •  =IF(B2>=40,"Pass","Fail")  •  =COUNTIF(A2:A6,"Office")  •  =SUMIF(A2:A6,"Office",B2:B6)  •  =VLOOKUP(E2,A2:C5,3,FALSE)',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Worksheet যাচাই করুন'),
        ),
      ),
    );
  }
}
