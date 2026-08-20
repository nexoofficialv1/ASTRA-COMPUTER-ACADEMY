class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.questionEn = '',
    this.optionsEn = const [],
    this.explanationEn = '',
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  final String questionEn;
  final List<String> optionsEn;
  final String explanationEn;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List<dynamic>),
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
      questionEn: json['questionEn'] as String? ?? '',
      optionsEn: List<String>.from(json['optionsEn'] as List<dynamic>? ?? const []),
      explanationEn: json['explanationEn'] as String? ?? '',
    );
  }
}
