import 'package:estudo/banner.dart';
import 'package:estudo/home.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:async';

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

class TriviaApp extends StatefulWidget {
  final bool isTimer; // Adiciona o parâmetro isTimer

  TriviaApp({required this.isTimer});

  @override
  _TriviaAppState createState() => _TriviaAppState();
}

class _TriviaAppState extends State<TriviaApp> with TickerProviderStateMixin {
  List<TriviaQuestion> questions = [];
  int score = 0;
  int correctAnswers = 0;
  final PageController _pageController = PageController();
  List<GlobalKey<FlipCardState>> _flipCardKeys = [];
  int currentQuestionIndex = 0;
  late AnimationController _animationController;
  int _secondsLeft = 10; // 10 seconds per question
  late DateTime _startTime; // Store start time of the game

  @override
  void initState() {
    super.initState();
    fetchQuestions();

    // Set up the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          if (_animationController.isCompleted) {
            moveToNextQuestion(); // Automatically move to the next question when timer reaches 0
          }
        });
      });
  }

  Future<void> fetchQuestions() async {
    try {
      var response =
          await Dio().get('https://the-trivia-api.com/v2/questions/');
      setState(() {
        questions = (response.data as List)
            .map((q) => TriviaQuestion.fromJson(q))
            .toList();

        _flipCardKeys =
            List.generate(questions.length, (_) => GlobalKey<FlipCardState>());
        _startTime = DateTime.now(); // Set the start time when the game begins
        if (widget.isTimer) {
          startTimer(); // Start the timer only if isTimer is true
        }
      });
    } catch (e) {
      print("Erro ao buscar perguntas: $e");
    }
  }

  void startTimer() {
    _secondsLeft = 10; // Reset to 10 seconds for each question
    _animationController.reset();
    _animationController.forward();
  }

  void showFeedbackMessage(bool isCorrect, String correctAnswer) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isCorrect ? "Correto!" : "Errado! Resposta correta: $correctAnswer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  void checkAnswer(String selected, String correct) async {
    bool isCorrect = selected == correct;
    showFeedbackMessage(isCorrect, correct);

    if (isCorrect) {
      setState(() {
        score++;
        correctAnswers++;
      });
    }

    // Stop the timer immediately when the answer is selected
    if (widget.isTimer) {
      _animationController.stop();
    }

    // Wait for the Snackbar to finish before moving to the next question
    await Future.delayed(Duration(seconds: 1));

    // Move to the next question and restart the timer
    moveToNextQuestion();
  }

  void moveToNextQuestion() {
    if (_pageController.page?.round() == questions.length - 1) {
      showGameOverDialog();
    } else {
      _pageController.nextPage(
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      if (widget.isTimer) {
        startTimer(); // Restart timer for the next question
      }
    }
  }

  void showGameOverDialog() {
    // Calcular o tempo total gasto em segundos se houver o timer
    final totalTime =
        widget.isTimer ? DateTime.now().difference(_startTime).inSeconds : 0;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar ao clicar fora
      builder: (context) => AlertDialog(
        title: const Text(
          "Fim do Jogo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          widget.isTimer
              ? "Sua pontuação: $score/${questions.length}\nAcertos: $correctAnswers\nTempo total: $totalTime segundos"
              : "Sua pontuação: $score/${questions.length}\nAcertos: $correctAnswers",
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: restartGame,
            child:
                Text("Jogar novamente", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: exitGame,
            child: Text("Sair", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void exitGame() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (Route<dynamic> route) => false, // Remove todas as páginas anteriores
    );
  }

  void restartGame() {
    Navigator.of(context).pop();
    setState(() {
      score = 0;
      correctAnswers = 0;
      currentQuestionIndex = 0;
    });
    _pageController.jumpToPage(0);
    _startTime =
        DateTime.now(); // Restart the start time when restarting the game
    if (widget.isTimer) {
      startTimer(); // Restart timer when restarting the game
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                AdMobBannerWidget(),
                widget.isTimer ? SizedBox(height: 20) : SizedBox.shrink(),
                if (widget.isTimer)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _animationController.value,
                          backgroundColor: Colors.white,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black54),
                          strokeWidth: 6,
                        ),
                        Text(
                          '${_secondsLeft - (_animationController.value * 10).toInt()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: FlipCard(
                          key: _flipCardKeys[index],
                          direction: FlipDirection.HORIZONTAL,
                          front: buildQuestionFront(questions[index]),
                          back: buildAnswerOptions(questions[index]),
                        ),
                      );
                    },
                  ),
                ),
                buildPagination(),
              ],
            ),
    );
  }

  Widget buildPagination() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.flip, color: Colors.white),
            onPressed: () {
              int currentIndex = _pageController.page?.round() ?? 0;
              if (_flipCardKeys[currentIndex].currentState?.isFront ?? false) {
                _flipCardKeys[currentIndex].currentState?.toggleCard();
              } else {
                _flipCardKeys[currentIndex].currentState?.toggleCard();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () {
              moveToNextQuestion();
            },
          ),
        ],
      ),
    );
  }

  Widget buildQuestionFront(TriviaQuestion questionData) {
    return Card(
      color: Colors.deepPurpleAccent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 320,
        height: 220,
        alignment: Alignment.center,
        padding: EdgeInsets.all(16),
        child: Text(
          questionData.question,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget buildAnswerOptions(TriviaQuestion questionData) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: questionData.options
            .map((option) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blueAccent.withOpacity(0.1),
                  ),
                  child: ListTile(
                    title: Text(option,
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    onTap: () =>
                        checkAnswer(option, questionData.correctAnswer),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
