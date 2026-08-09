import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/services/excel_formula_engine.dart';

void main() {
  const engine = ExcelFormulaEngine();

  test('IF returns string results from a numeric condition', () {
    final cells = <String, String>{'B2': '72', 'C2': '=IF(B2>=40,"Pass","Fail")'};
    expect(engine.evaluateCell('C2', cells).display, 'Pass');
  });

  test('COUNTIF counts matching text criteria', () {
    final cells = <String, String>{
      'A2': 'Office', 'A3': 'Travel', 'A4': 'Office', 'A5': 'Food', 'A6': 'Office',
      'D2': '=COUNTIF(A2:A6,"Office")',
    };
    expect(engine.evaluateCell('D2', cells).display, '3');
  });

  test('SUMIF sums a separate amount range', () {
    final cells = <String, String>{
      'A2': 'Office', 'B2': '500', 'A3': 'Travel', 'B3': '900',
      'A4': 'Office', 'B4': '750', 'A5': 'Food', 'B5': '350',
      'A6': 'Office', 'B6': '250', 'D3': '=SUMIF(A2:A6,"Office",B2:B6)',
    };
    expect(engine.evaluateCell('D3', cells).display, '1500');
  });

  test('VLOOKUP exact match returns requested table column', () {
    final cells = <String, String>{
      'A2': 'P101', 'B2': 'Keyboard', 'C2': '650',
      'A3': 'P102', 'B3': 'Mouse', 'C3': '350',
      'E2': 'P101', 'F2': '=VLOOKUP(E2,A2:C3,3,FALSE)',
    };
    expect(engine.evaluateCell('F2', cells).display, '650');
  });
}
