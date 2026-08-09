import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class ExcelWorkflowLabScreen extends StatefulWidget {
  const ExcelWorkflowLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<ExcelWorkflowLabScreen> createState() => _ExcelWorkflowLabScreenState();
}

class _ExcelWorkflowLabScreenState extends State<ExcelWorkflowLabScreen> {
  String? _sortColumn;
  String _sortDirection = 'asc';
  String? _filterColumn;
  String? _filterValue;
  String _chartType = 'None';
  String _orientation = 'Portrait';
  bool _fitToOnePage = false;
  bool _printPreviewOpened = false;
  bool _submitting = false;

  List<String> get _headers =>
      (widget.lesson.practicalData['headers'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();

  List<List<String>> get _sourceRows =>
      (widget.lesson.practicalData['rows'] as List<dynamic>? ?? const [])
          .map((row) => (row as List<dynamic>).map((cell) => cell.toString()).toList())
          .toList();

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  List<String> _valuesForColumn(String? column) {
    if (column == null) return const [];
    final index = _headers.indexOf(column);
    if (index < 0) return const [];
    final values = <String>[];
    for (final row in _sourceRows) {
      if (index < row.length && !values.contains(row[index])) values.add(row[index]);
    }
    return values;
  }

  num? _number(String value) => num.tryParse(value.replaceAll('%', '').trim());

  List<List<String>> get _visibleRows {
    var rows = _sourceRows.map((row) => List<String>.from(row)).toList();
    if (_filterColumn != null && _filterValue != null) {
      final index = _headers.indexOf(_filterColumn!);
      if (index >= 0) {
        rows = rows.where((row) => index < row.length && row[index] == _filterValue).toList();
      }
    }
    if (_sortColumn != null) {
      final index = _headers.indexOf(_sortColumn!);
      if (index >= 0) {
        rows.sort((a, b) {
          final left = index < a.length ? a[index] : '';
          final right = index < b.length ? b[index] : '';
          final leftNumber = _number(left);
          final rightNumber = _number(right);
          final result = leftNumber != null && rightNumber != null
              ? leftNumber.compareTo(rightNumber)
              : left.toLowerCase().compareTo(right.toLowerCase());
          return _sortDirection == 'desc' ? -result : result;
        });
      }
    }
    return rows;
  }

  List<(String, bool)> _checks() {
    final checks = <(String, bool)>[];
    if (_task['sortColumn'] != null) {
      checks.add(('Sort column: ${_task['sortColumn']}', _sortColumn == _task['sortColumn']));
    }
    if (_task['sortDirection'] != null) {
      checks.add(('Sort direction: ${_task['sortDirection']}', _sortDirection == _task['sortDirection']));
    }
    if (_task['filterColumn'] != null) {
      checks.add(('Filter column: ${_task['filterColumn']}', _filterColumn == _task['filterColumn']));
    }
    if (_task['filterValue'] != null) {
      checks.add(('Filter value: ${_task['filterValue']}', _filterValue == _task['filterValue']));
    }
    if (_task['chartType'] != null) {
      checks.add(('Chart: ${_task['chartType']}', _chartType == _task['chartType']));
    }
    if (_task['orientation'] != null) {
      checks.add(('Orientation: ${_task['orientation']}', _orientation == _task['orientation']));
    }
    if (_task['requireFitToOnePage'] == true) {
      checks.add(('Fit sheet on one page', _fitToOnePage));
    }
    if (_task['requirePrintPreview'] == true) {
      checks.add(('Print Preview opened', _printPreviewOpened));
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
      practicalKind: widget.lesson.practicalKind ?? 'excel_workflow',
      score: score,
      metrics: {
        'sortColumn': _sortColumn,
        'sortDirection': _sortDirection,
        'filterColumn': _filterColumn,
        'filterValue': _filterValue,
        'chartType': _chartType,
        'orientation': _orientation,
        'fitToOnePage': _fitToOnePage,
        'printPreview': _printPreviewOpened,
        'visibleRows': _visibleRows.length,
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excel Workflow — $score%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
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

  Widget _tablePreview() {
    final rows = _visibleRows;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [for (final header in _headers) DataColumn(label: Text(header))],
        rows: [
          for (final row in rows)
            DataRow(
              cells: [
                for (var i = 0; i < _headers.length; i++)
                  DataCell(Text(i < row.length ? row[i] : '')),
              ],
            ),
        ],
      ),
    );
  }

  Widget _chartPreview() {
    if (_chartType == 'None') return const SizedBox.shrink();
    final values = _visibleRows
        .expand((row) => row)
        .map(_number)
        .whereType<num>()
        .take(5)
        .toList();
    if (values.isEmpty) return const Text('Chart preview-এর জন্য numeric data নেই।');
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_chartType Chart Preview', style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final value in values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(
                          height: maxValue == 0 ? 8 : 120 * (value.toDouble() / maxValue),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                          alignment: Alignment.topCenter,
                          child: Text('$value', style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.lesson.practicalData['instruction'] as String? ??
        'Sort, Filter, Chart বা Print settings task সম্পন্ন করুন।';
    final filterValues = _valuesForColumn(_filterColumn);

    return Scaffold(
      appBar: AppBar(title: const Text('Excel Analysis & Print Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Text(instruction, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5)),
          const SizedBox(height: 12),
          _tablePreview(),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _sortColumn,
                    decoration: const InputDecoration(labelText: 'Sort by'),
                    items: [for (final header in _headers) DropdownMenuItem(value: header, child: Text(header))],
                    onChanged: (value) => setState(() => _sortColumn = value),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'asc', label: Text('Ascending')),
                      ButtonSegment(value: 'desc', label: Text('Descending')),
                    ],
                    selected: {_sortDirection},
                    onSelectionChanged: (value) => setState(() => _sortDirection = value.first),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _filterColumn,
                    decoration: const InputDecoration(labelText: 'Filter column'),
                    items: [for (final header in _headers) DropdownMenuItem(value: header, child: Text(header))],
                    onChanged: (value) => setState(() {
                      _filterColumn = value;
                      _filterValue = null;
                    }),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    key: ValueKey('filter-value-$_filterColumn'),
                    initialValue: filterValues.contains(_filterValue) ? _filterValue : null,
                    decoration: const InputDecoration(labelText: 'Show only'),
                    items: [for (final value in filterValues) DropdownMenuItem(value: value, child: Text(value))],
                    onChanged: filterValues.isEmpty ? null : (value) => setState(() => _filterValue = value),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Chart Type'),
              trailing: DropdownButton<String>(
                value: _chartType,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None')),
                  DropdownMenuItem(value: 'Column', child: Text('Column')),
                  DropdownMenuItem(value: 'Bar', child: Text('Bar')),
                  DropdownMenuItem(value: 'Line', child: Text('Line')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _chartType = value);
                },
              ),
            ),
          ),
          _chartPreview(),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Print Orientation'),
                  trailing: DropdownButton<String>(
                    value: _orientation,
                    items: const [
                      DropdownMenuItem(value: 'Portrait', child: Text('Portrait')),
                      DropdownMenuItem(value: 'Landscape', child: Text('Landscape')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _orientation = value);
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('Fit sheet on one page'),
                  value: _fitToOnePage,
                  onChanged: (value) => setState(() => _fitToOnePage = value),
                ),
                ListTile(
                  leading: Icon(_printPreviewOpened ? Icons.check_circle : Icons.print_rounded),
                  title: const Text('Print Preview'),
                  trailing: OutlinedButton(
                    onPressed: () => setState(() => _printPreviewOpened = true),
                    child: const Text('Open'),
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
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Excel workflow যাচাই করুন'),
        ),
      ),
    );
  }
}
