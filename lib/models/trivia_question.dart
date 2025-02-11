class TriviaQuestion {
  final String question;
  final String correctAnswer;
  final List<String> options;

  TriviaQuestion({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    List<String> options = [...json['incorrectAnswers'], json['correctAnswer']];
    options.shuffle();
    return TriviaQuestion(
      question: json['question']['text'],
      correctAnswer: json['correctAnswer'],
      options: options,
    );
  }
}
