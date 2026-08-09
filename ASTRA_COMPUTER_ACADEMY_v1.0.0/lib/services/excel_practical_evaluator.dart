import 'excel_formula_engine.dart';

class ExcelPracticalCheck {
  const ExcelPracticalCheck({required this.label, required this.passed});

  final String label;
  final bool passed;
}

class ExcelPracticalResult {
  const ExcelPracticalResult({required this.score, required this.checks});

  final int score;
  final List<ExcelPracticalCheck> checks;
}

class ExcelPracticalEvaluator {
  const ExcelPracticalEvaluator({this.engine = const ExcelFormulaEngine()});

  final ExcelFormulaEngine engine;

  ExcelPracticalResult evaluate({
    required Map<String, dynamic> task,
    required Map<String, String> cells,
  }) {
    final checks = <ExcelPracticalCheck>[];
    final expectedCells = task['expectedCells'] as List<dynamic>? ?? const [];

    for (final rawExpectation in expectedCells) {
      final expected = Map<String, dynamic>.from(rawExpectation as Map);
      final reference = (expected['cell'] as String).toUpperCase();
      final label = expected['label'] as String? ?? reference;
      final raw = (cells[reference] ?? '').trim();
      final result = engine.evaluateCell(reference, cells);

      if (expected.containsKey('value')) {
        checks.add(
          ExcelPracticalCheck(
            label: '$label — result সঠিক',
            passed: _valueMatches(result, expected['value']),
          ),
        );
      }

      final requireFormula = expected['requireFormula'] == true;
      if (requireFormula) {
        checks.add(
          ExcelPracticalCheck(
            label: '$reference-এ formula ব্যবহার করা হয়েছে',
            passed: raw.startsWith('='),
          ),
        );
      }

      final expectedFormula = expected['formula'] as String?;
      final formulaAnyOf = expected['formulaAnyOf'] as List<dynamic>?;
      if (expectedFormula != null || formulaAnyOf != null) {
        final allowed = <String>{
          if (expectedFormula != null) engine.canonicalFormula(expectedFormula),
          if (formulaAnyOf != null)
            ...formulaAnyOf.map((item) => engine.canonicalFormula(item.toString())),
        };
        checks.add(
          ExcelPracticalCheck(
            label: '$reference-এ নির্ধারিত formula সঠিক',
            passed: allowed.contains(engine.canonicalFormula(raw)),
          ),
        );
      }
    }

    if (checks.isEmpty) return const ExcelPracticalResult(score: 0, checks: []);
    final passed = checks.where((check) => check.passed).length;
    return ExcelPracticalResult(
      score: ((passed / checks.length) * 100).round(),
      checks: checks,
    );
  }

  bool _valueMatches(ExcelEvaluation actual, Object? expected) {
    if (actual.isError) return false;
    if (expected is num) {
      if (actual.value is! num) return false;
      return ((actual.value as num).toDouble() - expected.toDouble()).abs() < 0.000001;
    }
    return actual.display.trim().toLowerCase() == expected.toString().trim().toLowerCase();
  }
}
