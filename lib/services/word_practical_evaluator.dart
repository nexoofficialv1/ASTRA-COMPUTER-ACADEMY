class WordPracticalSubmission {
  const WordPracticalSubmission({
    required this.headingText,
    required this.paragraphText,
    required this.headingBold,
    required this.headingItalic,
    required this.headingUnderline,
    required this.headingFontSize,
    required this.headingAlignment,
    required this.paragraphBold,
    required this.paragraphItalic,
    required this.paragraphUnderline,
    required this.paragraphFontSize,
    required this.paragraphAlignment,
    required this.tableValues,
  });

  final String headingText;
  final String paragraphText;
  final bool headingBold;
  final bool headingItalic;
  final bool headingUnderline;
  final double headingFontSize;
  final String headingAlignment;
  final bool paragraphBold;
  final bool paragraphItalic;
  final bool paragraphUnderline;
  final double paragraphFontSize;
  final String paragraphAlignment;
  final List<List<String>> tableValues;
}

class WordPracticalCheck {
  const WordPracticalCheck({
    required this.label,
    required this.passed,
  });

  final String label;
  final bool passed;
}

class WordPracticalResult {
  const WordPracticalResult({
    required this.score,
    required this.checks,
  });

  final int score;
  final List<WordPracticalCheck> checks;
}

class WordPracticalEvaluator {
  const WordPracticalEvaluator();

  String _normalizeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  bool _sameText(String actual, String expected) {
    return _normalizeText(actual) == _normalizeText(expected);
  }

  void _checkBool(
    List<WordPracticalCheck> checks,
    Map<String, dynamic> expected,
    String key,
    bool actual,
    String label,
  ) {
    if (!expected.containsKey(key)) return;
    checks.add(
      WordPracticalCheck(
        label: label,
        passed: actual == (expected[key] as bool),
      ),
    );
  }

  void _checkBlockStyle({
    required List<WordPracticalCheck> checks,
    required Map<String, dynamic> expected,
    required String prefix,
    required bool bold,
    required bool italic,
    required bool underline,
    required double fontSize,
    required String alignment,
  }) {
    _checkBool(checks, expected, 'bold', bold, '$prefix Bold');
    _checkBool(checks, expected, 'italic', italic, '$prefix Italic');
    _checkBool(checks, expected, 'underline', underline, '$prefix Underline');

    if (expected.containsKey('fontSize')) {
      final target = (expected['fontSize'] as num).toDouble();
      checks.add(
        WordPracticalCheck(
          label: '$prefix Font Size ${target.toStringAsFixed(target % 1 == 0 ? 0 : 1)}',
          passed: (fontSize - target).abs() < 0.01,
        ),
      );
    }

    if (expected.containsKey('alignment')) {
      final target = (expected['alignment'] as String).toLowerCase();
      checks.add(
        WordPracticalCheck(
          label: '$prefix ${target[0].toUpperCase()}${target.substring(1)} Alignment',
          passed: alignment.toLowerCase() == target,
        ),
      );
    }
  }

  WordPracticalResult evaluate({
    required Map<String, dynamic> task,
    required WordPracticalSubmission submission,
  }) {
    final checks = <WordPracticalCheck>[];

    if (task.containsKey('headingText')) {
      checks.add(
        WordPracticalCheck(
          label: 'Heading text ঠিক আছে',
          passed: _sameText(
            submission.headingText,
            task['headingText'] as String,
          ),
        ),
      );
    }

    if (task.containsKey('paragraphText')) {
      checks.add(
        WordPracticalCheck(
          label: 'Paragraph text ঠিক আছে',
          passed: _sameText(
            submission.paragraphText,
            task['paragraphText'] as String,
          ),
        ),
      );
    }

    final headingStyle = task['headingStyle'];
    if (headingStyle is Map) {
      _checkBlockStyle(
        checks: checks,
        expected: Map<String, dynamic>.from(headingStyle),
        prefix: 'Heading',
        bold: submission.headingBold,
        italic: submission.headingItalic,
        underline: submission.headingUnderline,
        fontSize: submission.headingFontSize,
        alignment: submission.headingAlignment,
      );
    }

    final paragraphStyle = task['paragraphStyle'];
    if (paragraphStyle is Map) {
      _checkBlockStyle(
        checks: checks,
        expected: Map<String, dynamic>.from(paragraphStyle),
        prefix: 'Paragraph',
        bold: submission.paragraphBold,
        italic: submission.paragraphItalic,
        underline: submission.paragraphUnderline,
        fontSize: submission.paragraphFontSize,
        alignment: submission.paragraphAlignment,
      );
    }

    final table = task['table'];
    if (table is Map) {
      final expected = Map<String, dynamic>.from(table);
      final rows = expected['rows'] as int?;
      final columns = expected['columns'] as int?;
      if (rows != null && columns != null) {
        final actualRows = submission.tableValues.length;
        final actualColumns = actualRows == 0 ? 0 : submission.tableValues.first.length;
        checks.add(
          WordPracticalCheck(
            label: '$rows × $columns Table তৈরি',
            passed: actualRows == rows && actualColumns == columns,
          ),
        );
      }

      final expectedCells = expected['cells'];
      if (expectedCells is List) {
        final targetRows = expectedCells
            .map((row) => List<String>.from(row as List<dynamic>))
            .toList();
        var contentMatches = targetRows.length == submission.tableValues.length;
        if (contentMatches) {
          for (var r = 0; r < targetRows.length && contentMatches; r++) {
            if (targetRows[r].length != submission.tableValues[r].length) {
              contentMatches = false;
              break;
            }
            for (var c = 0; c < targetRows[r].length; c++) {
              if (!_sameText(submission.tableValues[r][c], targetRows[r][c])) {
                contentMatches = false;
                break;
              }
            }
          }
        }
        checks.add(
          WordPracticalCheck(
            label: 'Table-এর data ঠিক আছে',
            passed: contentMatches,
          ),
        );
      }
    }

    if (checks.isEmpty) {
      return const WordPracticalResult(score: 0, checks: []);
    }

    final passed = checks.where((check) => check.passed).length;
    return WordPracticalResult(
      score: ((passed / checks.length) * 100).round(),
      checks: checks,
    );
  }
}
