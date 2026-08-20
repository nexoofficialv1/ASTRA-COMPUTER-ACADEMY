import 'package:flutter_test/flutter_test.dart';
import 'package:astra_computer_academy/models/course.dart';
import 'package:astra_computer_academy/models/lesson.dart';
import 'package:astra_computer_academy/models/quiz_question.dart';
import 'package:astra_computer_academy/services/school_assessment_service.dart';

void main() {
  const question = QuizQuestion(
    question: 'Q',
    options: ['A', 'B'],
    correctIndex: 1,
    explanation: 'B',
  );

  Course course(String id) => Course(
        id: id,
        title: id,
        titleBn: id,
        subtitleBn: id,
        icon: '📘',
        level: 'Class V',
        track: 'school',
        grade: 5,
        curriculumLabel: 'Class V',
        lessons: const [
          Lesson(
            id: 'l1',
            titleBn: 'L1',
            summaryBn: 'S',
            durationMinutes: 1,
            type: 'theory',
            contentBn: [],
            steps: [],
            quiz: [question],
            practicalKind: null,
            practicalData: {},
          ),
        ],
      );

  test('chapter assessment ids are stable', () {
    final item = course('c5_demo');
    expect(
      SchoolAssessmentService.chapterTestId(item),
      'school_c5_chapter_test_c5_demo',
    );
    expect(
      SchoolAssessmentService.class5FinalExamId,
      'school_c5_final_exam',
    );
  });

  test('chapter scoring uses answer correctness', () {
    const service = SchoolAssessmentService();
    final questions = service.chapterQuestions(course('c5_demo'));
    expect(questions.length, 1);
    expect(
      service.scoreQuiz(questions: questions, answers: {0: 1}),
      100,
    );
    expect(
      service.scoreQuiz(questions: questions, answers: {0: 0}),
      0,
    );
  });

  test('final exam uses one question from each school chapter', () {
    const service = SchoolAssessmentService();
    final questions = service.finalQuestions([
      course('c1'),
      course('c2'),
      course('c3'),
    ]);
    expect(questions.length, 3);
    expect(
      service.scoreFinal(
        questions: questions,
        answers: {0: 1, 1: 1, 2: 1},
      ),
      100,
    );
  });
}
