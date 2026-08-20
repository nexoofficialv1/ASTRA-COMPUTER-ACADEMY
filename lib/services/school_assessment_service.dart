import '../models/course.dart';
import '../models/quiz_question.dart';

class SchoolAssessmentService {
  const SchoolAssessmentService();

  static const int chapterPassScore = 60;
  static const int finalPassScore = 70;
  static const String class5FinalExamId = 'school_c5_final_exam';

  static String chapterTestId(Course course) =>
      'school_c5_chapter_test_${course.id}';

  List<QuizQuestion> chapterQuestions(Course course) {
    return [
      for (final lesson in course.lessons)
        for (final question in lesson.quiz) question,
    ];
  }

  List<Class5FinalQuestion> finalQuestions(List<Course> courses) {
    final result = <Class5FinalQuestion>[];
    for (final course in courses.where((item) => item.isSchoolCourse)) {
      final questions = chapterQuestions(course);
      if (questions.isEmpty) continue;
      result.add(
        Class5FinalQuestion(
          chapterTitle: course.titleBn,
          question: questions.first,
        ),
      );
    }
    return result;
  }

  int scoreQuiz({
    required List<QuizQuestion> questions,
    required Map<int, int> answers,
  }) {
    if (questions.isEmpty) return 0;
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].correctIndex) correct++;
    }
    return ((correct / questions.length) * 100).round();
  }

  int scoreFinal({
    required List<Class5FinalQuestion> questions,
    required Map<int, int> answers,
  }) {
    if (questions.isEmpty) return 0;
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].question.correctIndex) correct++;
    }
    return ((correct / questions.length) * 100).round();
  }
}

class Class5FinalQuestion {
  const Class5FinalQuestion({
    required this.chapterTitle,
    required this.question,
  });

  final String chapterTitle;
  final QuizQuestion question;
}
