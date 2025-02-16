import 'dart:developer';

import 'package:estudo/models/trivia_question.dart';
import 'package:estudo/screens/home_screen.dart';
import 'package:estudo/services/auth.dart';
import 'package:estudo/services/competitor.dart';
import 'package:estudo/services/multiplayer.dart';
import 'package:estudo/services/room.dart';
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
  final RoomService _roomService = RoomService();

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

    fetchQuestions();
    _listenAllCompetitorsFinished();
  }

  void _listenAllCompetitorsFinished() {
    _roomService.getRoomStream(widget.roomId).listen((snapshot) async {
      if (snapshot.exists) {
        final roomData = snapshot.data() as Map<String, dynamic>;

        if (roomData['competitors'] != null) {
          final competitors = (roomData['competitors'] as Map<String, dynamic>)
              .values
              .map((competitor) => CompetitorModel.fromMap(competitor))
              .toList();

          // Verifica se todos os competidores terminaram
          if (competitors.every((c) => c.status == 'finished')) {
            // Atualiza o status da sala para 'finished'
            await _roomService.updateRoomStatus(widget.roomId, 'finished');

            // Ordena os competidores por pontuação (do maior para o menor)
            competitors.sort((a, b) => b.score.compareTo(a.score));

            // Exibe o popup com o ranking
            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Ranking da Sala",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: competitors.length,
                      itemBuilder: (context, index) {
                        final competitor = competitors[index];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: competitor.photoUrl.isNotEmpty
                                ? NetworkImage(competitor.photoUrl)
                                : null,
                            child: competitor.photoUrl.isEmpty
                                ? const Icon(Icons.person,
                                    size: 20, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            competitor.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            "Pontos: ${competitor.score}",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fecha o popup
                        exitGame(); // Sai do jogo
                      },
                      child: const Text(
                        "Sair",
                        style: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ],
                ),
              );
            }
          } else {
            // Mostra SnackBar para competidores individuais que terminaram
            for (final competitor in competitors) {
              if (competitor.status == 'finished') {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${competitor.name} terminou."),
                    ),
                  );
                }
              }
            }
          }
        }
      }
    });
  }

  Future<void> fetchQuestions() async {
    try {
      if (widget.playerOnline) {
        final roomQuestions =
            await _multiplayerService.getRoomQuestions(widget.roomId);
        if (roomQuestions.isEmpty) {
          throw Exception("Nenhuma pergunta encontrada na sala.");
        }
        setState(() {
          questions = roomQuestions;
        });
      } else {
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
          widget.roomId,
          _authService.currentUser!.uid,
          score,
        );
      }
    }

    if (widget.isTimer) {
      _animationController.stop();
    }

    await Future.delayed(const Duration(seconds: 1));

    moveToNextQuestion();
  }

  void moveToNextQuestion() async {
    if (_pageController.page?.round() == questions.length - 1) {
      await _multiplayerService.updateCompetitorStatus(
        widget.roomId,
        _authService.currentUser!.uid,
        'finished',
      );

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
          Visibility(
            visible: !widget.playerOnline,
            child: TextButton(
              onPressed: restartGame,
              child: const Text(
                "Jogar novamente",
                style: TextStyle(color: Colors.blue),
              ),
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
