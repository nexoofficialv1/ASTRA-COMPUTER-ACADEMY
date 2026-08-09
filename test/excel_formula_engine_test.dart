import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/services/excel_formula_engine.dart';

void main() {
  const engine = ExcelFormulaEngine();

  test('evaluates basic cell arithmetic', () {
    final cells = <String, String>{
      'B2': '15000',
      'C2': '3000',
      'D2': '=B2+C2',
    };
    expect(engine.evaluateCell('D2', cells).display, '18000');
  });

  test('evaluates spreadsheet functions over ranges', () {
    final cells = <String, String>{
      'B2': '85',
      'B3': '78',
      'B4': '88',
      'B5': '91',
      'B7': '=SUM(B2:B5)',
      'B8': '=AVERAGE(B2:B5)',
      'B9': '=MAX(B2:B5)',
      'B10': '=MIN(B2:B5)',
      'B11': '=COUNT(B2:B5)',
    };
    expect(engine.evaluateCell('B7', cells).display, '342');
    expect(engine.evaluateCell('B8', cells).display, '85.5');
    expect(engine.evaluateCell('B9', cells).display, '91');
    expect(engine.evaluateCell('B10', cells).display, '78');
    expect(engine.evaluateCell('B11', cells).display, '4');
  });

  test('detects circular references', () {
    final cells = <String, String>{'A1': '=B1', 'B1': '=A1'};
    expect(engine.evaluateCell('A1', cells).error, '#CIRC!');
  });
}
