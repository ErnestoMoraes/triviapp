import 'package:flutter/material.dart';

void showFeedbackMessage(
    bool isCorrect, String correctAnswer, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isCorrect ? "Correto!" : "Errado! Resposta correta: $correctAnswer",
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: isCorrect ? Colors.green : Colors.red,
    ),
  );
}
