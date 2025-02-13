import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estudo/models/trivia_question.dart';

class MultiplayerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para adicionar perguntas à sala
  Future<void> addQuestionsToRoom(
      String roomId, List<TriviaQuestion> questions) async {
    List<Map<String, dynamic>> questionsData =
        questions.map((q) => q.toJson()).toList();
    await _firestore.collection('rooms').doc(roomId).update({
      'questions': questionsData,
    });
  }

  // Obter perguntas da sala
  Future<List<TriviaQuestion>> getRoomQuestions(String roomId) async {
    final snapshot = await _firestore.collection('rooms').doc(roomId).get();
    if (snapshot.exists) {
      // Verifica se o campo 'questions' existe e é uma lista
      if (snapshot.data()?.containsKey('questions') ?? false) {
        List<dynamic> questionsData = snapshot.data()!['questions'];
        return questionsData
            .map((q) => TriviaQuestion.fromJsonFirebase(q))
            .toList();
      } else {
        log("Campo 'questions' não encontrado ou não é uma lista.");
        return [];
      }
    } else {
      log("Documento da sala não encontrado.");
      return [];
    }
  }

  // Enviar resposta do jogador
  Future<void> submitAnswer(String roomId, String userId, String answer) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('competitors')
        .doc(userId)
        .collection('answers')
        .add({'answer': answer, 'timestamp': FieldValue.serverTimestamp()});
  }

  // Atualizar pontuação do jogador
  Future<void> updateScore(String roomId, String userId, int score) async {
    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('competitors')
        .doc(userId)
        .update({'score': score});
  }

  // Obter stream de atualizações da sala
  Stream<DocumentSnapshot> getRoomUpdates(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots();
  }
}
