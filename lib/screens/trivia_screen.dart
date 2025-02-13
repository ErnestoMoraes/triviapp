import 'dart:developer';

import 'package:estudo/models/trivia_question.dart';
import 'package:estudo/screens/home_screen.dart';
import 'package:estudo/services/auth.dart';
import 'package:estudo/services/multiplayer.dart';
import 'package:estudo/utils/snackbar.dart';
import 'package:estudo/widgets/banner.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flip_card/flip_card.dart';
import 'dart:async';

class TriviaScreen extends StatefulWidget {
  final bool isTimer;
  final bool playerOnline;
  final String roomId;

  const TriviaScreen({
    super.key,
    required this.isTimer,
    this.playerOnline = false,
    this.roomId = '',
  });

  @override
  TriviaScreenState createState() => TriviaScreenState();
}

class TriviaScreenState extends State<TriviaScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  List<TriviaQuestion> questions = [];
  int score = 0;
  final PageController _pageController = PageController();
  List<GlobalKey<FlipCardState>> _flipCardKeys = [];
  late AnimationController _animationController;
  int _secondsLeft = 10;
  late DateTime _startTime;
  final MultiplayerService _multiplayerService = MultiplayerService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          if (_animationController.isCompleted) {
            moveToNextQuestion();
          }
        });
      });

    // Busca as perguntas (do Firestore ou da API)
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      if (widget.playerOnline) {
        // No modo multiplayer, carrega as perguntas do Firestore
        final roomQuestions =
            await _multiplayerService.getRoomQuestions(widget.roomId);
        if (roomQuestions.isEmpty) {
          throw Exception("Nenhuma pergunta encontrada na sala.");
        }
        setState(() {
          questions = roomQuestions;
        });
      } else {
        // No modo single-player, busca as perguntas da API
        var response =
            await Dio().get('https://the-trivia-api.com/v2/questions/');
        List<TriviaQuestion> questions = (response.data as List)
            .map((q) => TriviaQuestion.fromJson(q))
            .toList();
        setState(() {
          this.questions = questions;
        });
      }

      // Inicializa o jogo
      _flipCardKeys =
          List.generate(questions.length, (_) => GlobalKey<FlipCardState>());
      _startTime = DateTime.now();
      if (widget.isTimer) {
        startTimer();
      }
    } catch (e) {
      log("Erro ao buscar perguntas: $e");
      // Exibe uma mensagem de erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar as perguntas: $e"),
        ),
      );
    }
  }

  void startTimer() {
    _secondsLeft = 10;
    _animationController.reset();
    _animationController.forward();
  }

  void checkAnswer(
      String selected, String correct, BuildContext context) async {
    bool isCorrect = selected == correct;

    showFeedbackMessage(isCorrect, correct, context);

    if (isCorrect) {
      setState(() {
        score++;
      });
      if (widget.playerOnline) {
        await _multiplayerService.updateScore(
            widget.roomId, _authService.currentUser!.uid, score);
      }
    }

    if (widget.isTimer) {
      _animationController.stop();
    }

    await Future.delayed(const Duration(seconds: 1));

    moveToNextQuestion();
  }

  void moveToNextQuestion() {
    if (_pageController.page?.round() == questions.length - 1) {
      showGameOverDialog();
    } else {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      if (widget.isTimer) {
        startTimer();
      }
    }
  }

  void showGameOverDialog() {
    final totalTime =
        widget.isTimer ? DateTime.now().difference(_startTime).inSeconds : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Fim do Jogo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          widget.isTimer
              ? "Sua pontuação: $score/${questions.length}\nTempo total: $totalTime segundos"
              : "Sua pontuação: $score/${questions.length}",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: restartGame,
            child: const Text(
              "Jogar novamente",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: exitGame,
            child: const Text(
              "Sair",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void exitGame() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void restartGame() {
    Navigator.of(context).pop();
    setState(() {
      score = 0;
    });
    _pageController.jumpToPage(0);
    _startTime = DateTime.now();
    if (widget.isTimer) {
      startTimer();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const AdMobBannerWidget(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Pergunta ${_currentQuestionIndex + 1}/10',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                widget.isTimer
                    ? const SizedBox(height: 20)
                    : const SizedBox.shrink(),
                if (widget.isTimer)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _animationController.value,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.black54,
                          ),
                          strokeWidth: 6,
                        ),
                        Text(
                          '${_secondsLeft - (_animationController.value * 10).toInt()}',
                          style: const TextStyle(
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
                    physics: const NeverScrollableScrollPhysics(),
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
      padding: const EdgeInsets.only(bottom: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.flip, color: Colors.white),
            onPressed: () {
              int currentIndex = _pageController.page?.round() ?? 0;
              _flipCardKeys[currentIndex].currentState?.toggleCard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: moveToNextQuestion,
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
        padding: const EdgeInsets.all(16),
        child: Text(
          questionData.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                    title: Text(
                      option,
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    onTap: () => checkAnswer(
                      option,
                      questionData.correctAnswer,
                      context,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
