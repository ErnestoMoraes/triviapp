class TriviaQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  TriviaQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    List<String> options = [...json['incorrectAnswers'], json['correctAnswer']];
    options.shuffle();
    return TriviaQuestion(
      question: json['question']['text'],
      correctAnswer: json['correctAnswer'],
      options: options,
    );
  }

  factory TriviaQuestion.fromJsonFirebase(Map<String, dynamic> json) {
    return TriviaQuestion(
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      options: List<String>.from(json['options']),
    );
  }
}
