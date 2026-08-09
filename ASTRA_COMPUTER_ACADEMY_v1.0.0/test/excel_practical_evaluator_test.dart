import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/services/excel_practical_evaluator.dart';

void main() {
  const evaluator = ExcelPracticalEvaluator();

  test('requires both correct result and expected formula', () {
    final task = <String, dynamic>{
      'expectedCells': [
        {
          'cell': 'D2',
          'value': 18000,
          'requireFormula': true,
          'formula': '=B2+C2',
        },
      ],
    };

    final correct = evaluator.evaluate(
      task: task,
      cells: {'B2': '15000', 'C2': '3000', 'D2': '=B2+C2'},
    );
    expect(correct.score, 100);

    final hardCoded = evaluator.evaluate(
      task: task,
      cells: {'B2': '15000', 'C2': '3000', 'D2': '18000'},
    );
    expect(hardCoded.score, lessThan(100));
  });
}
