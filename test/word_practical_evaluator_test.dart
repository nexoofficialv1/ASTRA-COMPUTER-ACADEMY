import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/services/word_practical_evaluator.dart';

void main() {
  const evaluator = WordPracticalEvaluator();

  test('perfect formatting submission scores 100', () {
    final result = evaluator.evaluate(
      task: const {
        'headingText': 'COMPUTER TRAINING NOTICE',
        'paragraphText': 'All students must attend.',
        'headingStyle': {'bold': true, 'fontSize': 16},
        'paragraphStyle': {'alignment': 'justify'},
      },
      submission: const WordPracticalSubmission(
        headingText: ' COMPUTER   TRAINING NOTICE ',
        paragraphText: 'All students must attend.',
        headingBold: true,
        headingItalic: false,
        headingUnderline: false,
        headingFontSize: 16,
        headingAlignment: 'left',
        paragraphBold: false,
        paragraphItalic: false,
        paragraphUnderline: false,
        paragraphFontSize: 12,
        paragraphAlignment: 'justify',
        tableValues: [],
      ),
    );

    expect(result.score, 100);
    expect(result.checks.every((check) => check.passed), isTrue);
  });

  test('table dimensions and content are validated', () {
    final result = evaluator.evaluate(
      task: const {
        'table': {
          'rows': 2,
          'columns': 2,
          'cells': [
            ['Name', 'Score'],
            ['Riya', '90'],
          ],
        },
      },
      submission: const WordPracticalSubmission(
        headingText: '',
        paragraphText: '',
        headingBold: false,
        headingItalic: false,
        headingUnderline: false,
        headingFontSize: 14,
        headingAlignment: 'left',
        paragraphBold: false,
        paragraphItalic: false,
        paragraphUnderline: false,
        paragraphFontSize: 12,
        paragraphAlignment: 'left',
        tableValues: [
          ['Name', 'Score'],
          ['Riya', '80'],
        ],
      ),
    );

    expect(result.score, 50);
    expect(result.checks.length, 2);
    expect(result.checks.first.passed, isTrue);
    expect(result.checks.last.passed, isFalse);
  });
}
