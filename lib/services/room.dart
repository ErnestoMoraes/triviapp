import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:estudo/models/trivia_question.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRoom(String userId, String userName) async {
    try {
      // Busca as perguntas da API
      var response =
          await Dio().get('https://the-trivia-api.com/v2/questions/');
      List<TriviaQuestion> questions = (response.data as List)
          .map((q) => TriviaQuestion.fromJson(q))
          .toList();

      // Converte as perguntas para um formato salvável no Firestore
      List<Map<String, dynamic>> questionsData =
          questions.map((q) => q.toJson()).toList();

      // Cria a sala com as perguntas
      String roomId = _firestore.collection('rooms').doc().id;
      await _firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
        'competitors': {
          userId: {
            'name': userName,
            'score': 0,
          }
        },
        'questions':
            questionsData, // Certifique-se de que este campo é uma lista
      });

      return roomId;
    } catch (e) {
      log("Erro ao criar a sala: $e");
      throw Exception("Erro ao criar a sala");
    }
  }

  Future<bool> joinRoom(String roomId, String userId, String userName) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      await _firestore.collection('rooms').doc(roomId).update({
        'competitors.$userId': {
          'name': userName,
          'score': 0,
        }
      });
      return true;
    }
    return false;
  }

  Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots();
  }
}
