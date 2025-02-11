import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../models/trivia_question.dart';

class TriviaCard extends StatelessWidget {
  final TriviaQuestion question;
  final Function(String) onAnswerSelected;
  final GlobalKey<FlipCardState> cardKey;

  const TriviaCard({
    super.key,
    required this.question,
    required this.onAnswerSelected,
    required this.cardKey,
  });

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: cardKey,
      direction: FlipDirection.HORIZONTAL,
      front: _buildFrontCard(),
      back: _buildBackCard(),
    );
  }

  Widget _buildFrontCard() {
    return Card(
      color: Colors.deepPurpleAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: question.options
            .map((option) => ListTile(
                  title: Text(
                    option,
                    style: const TextStyle(fontSize: 18),
                  ),
                  onTap: () => onAnswerSelected(option),
                ))
            .toList(),
      ),
    );
  }
}
