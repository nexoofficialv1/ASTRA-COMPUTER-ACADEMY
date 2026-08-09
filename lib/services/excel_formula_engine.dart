class ExcelEvaluation {
  const ExcelEvaluation({this.value, this.error});

  final Object? value;
  final String? error;

  bool get isError => error != null;
  bool get isNumber => value is num;

  String get display {
    if (error != null) return error!;
    final current = value;
    if (current == null) return '';
    if (current is num) {
      final doubleValue = current.toDouble();
      if (doubleValue == doubleValue.roundToDouble()) return doubleValue.toInt().toString();
      return doubleValue
          .toStringAsFixed(2)
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return current.toString();
  }
}

class ExcelFormulaEngine {
  const ExcelFormulaEngine();

  ExcelEvaluation evaluateCell(String reference, Map<String, String> cells) {
    final normalized = <String, String>{
      for (final entry in cells.entries) entry.key.toUpperCase(): entry.value,
    };
    return _evaluateCell(reference.toUpperCase(), normalized, <String>{});
  }

  String canonicalFormula(String raw) => raw.replaceAll(RegExp(r'\s+'), '').toUpperCase();

  ExcelEvaluation _evaluateCell(
    String reference,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    if (visiting.contains(reference)) return const ExcelEvaluation(error: '#CIRC!');

    final raw = (cells[reference] ?? '').trim();
    if (raw.isEmpty) return const ExcelEvaluation(value: '');
    if (!raw.startsWith('=')) return ExcelEvaluation(value: _parseLiteral(raw));

    visiting.add(reference);
    final result = _evaluateFormula(raw.substring(1), cells, visiting);
    visiting.remove(reference);
    return result;
  }

  ExcelEvaluation _evaluateFormula(
    String expression,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    final source = expression.trim();
    final call = _functionCall(source);
    if (call != null) {
      final name = call.$1;
      final args = _splitArguments(call.$2);
      switch (name) {
        case 'SUM':
        case 'AVERAGE':
        case 'MIN':
        case 'MAX':
        case 'COUNT':
          return _aggregate(name, args, cells, visiting);
        case 'IF':
          return _ifFunction(args, cells, visiting);
        case 'COUNTIF':
          return _countIf(args, cells, visiting);
        case 'SUMIF':
          return _sumIf(args, cells, visiting);
        case 'VLOOKUP':
          return _vlookup(args, cells, visiting);
      }
    }

    try {
      final parser = _ArithmeticParser(
        source,
        (reference) {
          final result = _evaluateCell(reference, cells, visiting);
          if (result.isError) throw _FormulaException(result.error!);
          if (result.value is! num) throw const _FormulaException('#VALUE!');
          return (result.value as num).toDouble();
        },
      );
      return ExcelEvaluation(value: parser.parse());
    } on _FormulaException catch (error) {
      return ExcelEvaluation(error: error.code);
    } catch (_) {
      return const ExcelEvaluation(error: '#ERROR!');
    }
  }

  (String, String)? _functionCall(String source) {
    final match = RegExp(r'^([A-Z]+)\((.*)\)$', caseSensitive: false).firstMatch(source);
    if (match == null) return null;
    return (match.group(1)!.toUpperCase(), match.group(2)!);
  }

  ExcelEvaluation _aggregate(
    String name,
    List<String> args,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    final values = <double>[];
    for (final token in args) {
      final range = _parseRange(token);
      if (range != null) {
        for (final ref in range) {
          final result = _evaluateCell(ref, cells, visiting);
          if (result.isError) return result;
          if (result.value is num) values.add((result.value as num).toDouble());
        }
        continue;
      }
      final value = _valueToken(token, cells, visiting);
      if (value.$2 != null) return ExcelEvaluation(error: value.$2);
      if (value.$1 is num) values.add((value.$1 as num).toDouble());
    }

    switch (name) {
      case 'SUM':
        return ExcelEvaluation(value: values.fold<double>(0, (a, b) => a + b));
      case 'AVERAGE':
        if (values.isEmpty) return const ExcelEvaluation(error: '#DIV/0!');
        return ExcelEvaluation(value: values.fold<double>(0, (a, b) => a + b) / values.length);
      case 'MIN':
        return ExcelEvaluation(value: values.isEmpty ? 0 : values.reduce((a, b) => a < b ? a : b));
      case 'MAX':
        return ExcelEvaluation(value: values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b));
      case 'COUNT':
        return ExcelEvaluation(value: values.length.toDouble());
    }
    return const ExcelEvaluation(error: '#NAME?');
  }

  ExcelEvaluation _ifFunction(
    List<String> args,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    if (args.length != 3) return const ExcelEvaluation(error: '#ERROR!');
    final condition = _evaluateCondition(args[0], cells, visiting);
    if (condition.$2 != null) return ExcelEvaluation(error: condition.$2);
    final chosen = condition.$1 ? args[1] : args[2];
    final value = _valueToken(chosen, cells, visiting, allowFormulaExpression: true);
    return ExcelEvaluation(value: value.$1, error: value.$2);
  }

  ExcelEvaluation _countIf(
    List<String> args,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    if (args.length != 2) return const ExcelEvaluation(error: '#ERROR!');
    final refs = _parseRange(args[0]);
    if (refs == null) return const ExcelEvaluation(error: '#REF!');
    final criteria = _stripQuotes(args[1].trim());
    var count = 0;
    for (final ref in refs) {
      final result = _evaluateCell(ref, cells, visiting);
      if (result.isError) return result;
      if (_matchesCriteria(result.value, criteria)) count++;
    }
    return ExcelEvaluation(value: count.toDouble());
  }

  ExcelEvaluation _sumIf(
    List<String> args,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    if (args.length != 2 && args.length != 3) return const ExcelEvaluation(error: '#ERROR!');
    final criteriaRefs = _parseRange(args[0]);
    final sumRefs = args.length == 3 ? _parseRange(args[2]) : criteriaRefs;
    if (criteriaRefs == null || sumRefs == null || criteriaRefs.length != sumRefs.length) {
      return const ExcelEvaluation(error: '#REF!');
    }
    final criteria = _stripQuotes(args[1].trim());
    var sum = 0.0;
    for (var i = 0; i < criteriaRefs.length; i++) {
      final criteriaValue = _evaluateCell(criteriaRefs[i], cells, visiting);
      if (criteriaValue.isError) return criteriaValue;
      if (!_matchesCriteria(criteriaValue.value, criteria)) continue;
      final sumValue = _evaluateCell(sumRefs[i], cells, visiting);
      if (sumValue.isError) return sumValue;
      if (sumValue.value is num) sum += (sumValue.value as num).toDouble();
    }
    return ExcelEvaluation(value: sum);
  }

  ExcelEvaluation _vlookup(
    List<String> args,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    if (args.length < 3 || args.length > 4) return const ExcelEvaluation(error: '#ERROR!');
    if (args.length == 4) {
      final mode = _stripQuotes(args[3]).toUpperCase();
      if (mode != 'FALSE' && mode != '0') return const ExcelEvaluation(error: '#N/A');
    }

    final lookup = _valueToken(args[0], cells, visiting);
    if (lookup.$2 != null) return ExcelEvaluation(error: lookup.$2);
    final bounds = _rangeBounds(args[1]);
    if (bounds == null) return const ExcelEvaluation(error: '#REF!');
    final columnIndex = int.tryParse(_stripQuotes(args[2]));
    final width = bounds.$3 - bounds.$1 + 1;
    if (columnIndex == null || columnIndex < 1 || columnIndex > width) {
      return const ExcelEvaluation(error: '#REF!');
    }

    for (var row = bounds.$2; row <= bounds.$4; row++) {
      final firstRef = '${_columnName(bounds.$1)}$row';
      final first = _evaluateCell(firstRef, cells, visiting);
      if (first.isError) return first;
      if (_valuesEqual(first.value, lookup.$1)) {
        final targetColumn = bounds.$1 + columnIndex - 1;
        return _evaluateCell('${_columnName(targetColumn)}$row', cells, visiting);
      }
    }
    return const ExcelEvaluation(error: '#N/A');
  }

  (bool, String?) _evaluateCondition(
    String source,
    Map<String, String> cells,
    Set<String> visiting,
  ) {
    final match = RegExp(r'^(.*?)(>=|<=|<>|=|>|<)(.*)$').firstMatch(source.trim());
    if (match == null) {
      final value = _valueToken(source, cells, visiting);
      if (value.$2 != null) return (false, value.$2);
      if (value.$1 is bool) return (value.$1 as bool, null);
      if (value.$1 is num) return ((value.$1 as num) != 0, null);
      return ((value.$1?.toString().isNotEmpty ?? false), null);
    }

    final left = _valueToken(match.group(1)!, cells, visiting);
    final right = _valueToken(match.group(3)!, cells, visiting);
    if (left.$2 != null) return (false, left.$2);
    if (right.$2 != null) return (false, right.$2);
    final op = match.group(2)!;

    if (left.$1 is num && right.$1 is num) {
      final a = (left.$1 as num).toDouble();
      final b = (right.$1 as num).toDouble();
      return (_compareNumbers(a, b, op), null);
    }
    final a = left.$1?.toString().toLowerCase() ?? '';
    final b = right.$1?.toString().toLowerCase() ?? '';
    final cmp = a.compareTo(b);
    switch (op) {
      case '=':
        return (a == b, null);
      case '<>':
        return (a != b, null);
      case '>':
        return (cmp > 0, null);
      case '<':
        return (cmp < 0, null);
      case '>=':
        return (cmp >= 0, null);
      case '<=':
        return (cmp <= 0, null);
    }
    return (false, '#ERROR!');
  }

  bool _compareNumbers(double a, double b, String op) {
    switch (op) {
      case '=':
        return (a - b).abs() < 0.000001;
      case '<>':
        return (a - b).abs() >= 0.000001;
      case '>':
        return a > b;
      case '<':
        return a < b;
      case '>=':
        return a >= b;
      case '<=':
        return a <= b;
    }
    return false;
  }

  bool _matchesCriteria(Object? value, String criteria) {
    final match = RegExp(r'^(>=|<=|<>|=|>|<)(.*)$').firstMatch(criteria.trim());
    final op = match?.group(1) ?? '=';
    final expectedRaw = (match?.group(2) ?? criteria).trim();
    final expected = _parseLiteral(_stripQuotes(expectedRaw));

    if (value is num && expected is num) {
      return _compareNumbers(value.toDouble(), expected.toDouble(), op);
    }
    final a = value?.toString().toLowerCase() ?? '';
    final b = expected.toString().toLowerCase();
    if (op == '=') return a == b;
    if (op == '<>') return a != b;
    final cmp = a.compareTo(b);
    if (op == '>') return cmp > 0;
    if (op == '<') return cmp < 0;
    if (op == '>=') return cmp >= 0;
    if (op == '<=') return cmp <= 0;
    return false;
  }

  (Object?, String?) _valueToken(
    String token,
    Map<String, String> cells,
    Set<String> visiting, {
    bool allowFormulaExpression = false,
  }) {
    final trimmed = token.trim();
    if (_isQuoted(trimmed)) return (_stripQuotes(trimmed), null);
    if (trimmed.toUpperCase() == 'TRUE') return (true, null);
    if (trimmed.toUpperCase() == 'FALSE') return (false, null);

    final number = double.tryParse(trimmed.replaceAll(',', ''));
    if (number != null) return (number, null);

    if (RegExp(r'^[A-Z]+[1-9]\d*$', caseSensitive: false).hasMatch(trimmed)) {
      final result = _evaluateCell(trimmed.toUpperCase(), cells, visiting);
      return (result.value, result.error);
    }

    if (allowFormulaExpression) {
      final result = _evaluateFormula(trimmed, cells, visiting);
      return (result.value, result.error);
    }
    return (trimmed, null);
  }

  Object _parseLiteral(String raw) {
    final clean = raw.trim();
    final number = double.tryParse(clean.replaceAll(',', ''));
    if (number != null) return number;
    return _stripQuotes(clean);
  }

  bool _valuesEqual(Object? a, Object? b) {
    if (a is num && b is num) return (a.toDouble() - b.toDouble()).abs() < 0.000001;
    return (a?.toString().trim().toLowerCase() ?? '') == (b?.toString().trim().toLowerCase() ?? '');
  }

  List<String> _splitArguments(String source) {
    final result = <String>[];
    final buffer = StringBuffer();
    var depth = 0;
    var quoted = false;
    String? quote;
    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if ((char == '"' || char == "'") && (i == 0 || source[i - 1] != '\\')) {
        if (!quoted) {
          quoted = true;
          quote = char;
        } else if (quote == char) {
          quoted = false;
          quote = null;
        }
        buffer.write(char);
        continue;
      }
      if (!quoted) {
        if (char == '(') depth++;
        if (char == ')') depth--;
        if (char == ',' && depth == 0) {
          result.add(buffer.toString().trim());
          buffer.clear();
          continue;
        }
      }
      buffer.write(char);
    }
    if (buffer.isNotEmpty || source.trim().isNotEmpty) result.add(buffer.toString().trim());
    return result;
  }

  bool _isQuoted(String value) =>
      value.length >= 2 &&
      ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'")));

  String _stripQuotes(String value) {
    final clean = value.trim();
    return _isQuoted(clean) ? clean.substring(1, clean.length - 1) : clean;
  }

  List<String>? _parseRange(String token) {
    final bounds = _rangeBounds(token);
    if (bounds == null) return null;
    final result = <String>[];
    for (var row = bounds.$2; row <= bounds.$4; row++) {
      for (var col = bounds.$1; col <= bounds.$3; col++) {
        result.add('${_columnName(col)}$row');
      }
    }
    return result;
  }

  (int, int, int, int)? _rangeBounds(String token) {
    final match = RegExp(
      r'^([A-Z]+[1-9]\d*):([A-Z]+[1-9]\d*)$',
      caseSensitive: false,
    ).firstMatch(token.trim());
    if (match == null) return null;
    final a = _parseReference(match.group(1)!);
    final b = _parseReference(match.group(2)!);
    if (a == null || b == null) return null;
    final minCol = a.$1 < b.$1 ? a.$1 : b.$1;
    final maxCol = a.$1 > b.$1 ? a.$1 : b.$1;
    final minRow = a.$2 < b.$2 ? a.$2 : b.$2;
    final maxRow = a.$2 > b.$2 ? a.$2 : b.$2;
    return (minCol, minRow, maxCol, maxRow);
  }

  (int, int)? _parseReference(String reference) {
    final match = RegExp(r'^([A-Z]+)([1-9]\d*)$', caseSensitive: false)
        .firstMatch(reference.trim());
    if (match == null) return null;
    var column = 0;
    for (final code in match.group(1)!.toUpperCase().codeUnits) {
      column = (column * 26) + (code - 64);
    }
    return (column, int.parse(match.group(2)!));
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
}

class _FormulaException implements Exception {
  const _FormulaException(this.code);
  final String code;
}

class _ArithmeticParser {
  _ArithmeticParser(this.source, this.referenceResolver);

  final String source;
  final double Function(String reference) referenceResolver;
  int index = 0;

  double parse() {
    final value = _parseExpression();
    _skipSpaces();
    if (index != source.length) throw const _FormulaException('#ERROR!');
    return value;
  }

  double _parseExpression() {
    var value = _parseTerm();
    while (true) {
      _skipSpaces();
      if (_consume('+')) {
        value += _parseTerm();
      } else if (_consume('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parseFactor();
    while (true) {
      _skipSpaces();
      if (_consume('*')) {
        value *= _parseFactor();
      } else if (_consume('/')) {
        final divisor = _parseFactor();
        if (divisor == 0) throw const _FormulaException('#DIV/0!');
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parseFactor() {
    _skipSpaces();
    if (_consume('+')) return _parseFactor();
    if (_consume('-')) return -_parseFactor();

    if (_consume('(')) {
      final value = _parseExpression();
      _skipSpaces();
      if (!_consume(')')) throw const _FormulaException('#ERROR!');
      return value;
    }
    if (index >= source.length) throw const _FormulaException('#ERROR!');

    if (_isLetter(source.codeUnitAt(index))) {
      final start = index;
      while (index < source.length && _isLetter(source.codeUnitAt(index))) {
        index++;
      }
      final digitStart = index;
      while (index < source.length && _isDigit(source.codeUnitAt(index))) {
        index++;
      }
      if (digitStart == index) throw const _FormulaException('#NAME?');
      return referenceResolver(source.substring(start, index).toUpperCase());
    }

    final start = index;
    var dotSeen = false;
    while (index < source.length) {
      final code = source.codeUnitAt(index);
      if (_isDigit(code)) {
        index++;
        continue;
      }
      if (source[index] == '.' && !dotSeen) {
        dotSeen = true;
        index++;
        continue;
      }
      break;
    }
    if (start == index) throw const _FormulaException('#ERROR!');
    final number = double.tryParse(source.substring(start, index));
    if (number == null) throw const _FormulaException('#VALUE!');
    return number;
  }

  void _skipSpaces() {
    while (index < source.length && source[index].trim().isEmpty) {
      index++;
    }
  }

  bool _consume(String token) {
    if (index < source.length && source[index] == token) {
      index++;
      return true;
    }
    return false;
  }

  bool _isLetter(int code) =>
      (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  bool _isDigit(int code) => code >= 48 && code <= 57;
}
