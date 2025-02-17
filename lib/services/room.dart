import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:estudo/models/trivia_question.dart';

class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRoom(
    String userId,
    String userName,
    String photoUrl,
    String stauts,
  ) async {
    try {
      var response =
          await Dio().get('https://the-trivia-api.com/v2/questions/');
      List<TriviaQuestion> questions = (response.data as List)
          .map((q) => TriviaQuestion.fromJson(q))
          .toList();

      List<Map<String, dynamic>> questionsData =
          questions.map((q) => q.toJson()).toList();

      String roomId = _firestore.collection('rooms').doc().id;
      await _firestore.collection('rooms').doc(roomId).set({
        'status': 'waiting',
        'competitors': {
          userId: {
            'name': userName,
            'score': 0,
            'photoUrl': photoUrl,
            'status': stauts,
          }
        },
        'questions': questionsData,
      });

      return roomId;
    } catch (e) {
      log("Erro ao criar a sala: $e");
      throw Exception("Erro ao criar a sala");
    }
  }

  Future<void> startGame(String roomId, String userId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['competitors'].keys.first == userId) {
        await _firestore.collection('rooms').doc(roomId).update({
          'status': 'gameing',
        });
      }
    }
  }

  Future<bool> isCreatorRoom(String roomId, String userId) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return data['competitors'].keys.first == userId;
    }
    return false;
  }

  Future<bool> joinRoom(
    String roomId,
    String userId,
    String userName,
    String photoUrl,
    String status,
  ) async {
    final doc = await _firestore.collection('rooms').doc(roomId).get();
    if (doc.exists) {
      await _firestore.collection('rooms').doc(roomId).update({
        'competitors.$userId': {
          'name': userName,
          'score': 0,
          'photoUrl': photoUrl,
          'status': status,
        }
      });
      return true;
    }
    return false;
  }

  Stream<DocumentSnapshot> getRoomStream(String roomId) {
    return _firestore.collection('rooms').doc(roomId).snapshots();
  }

  // updateRoomStatus
  Future<void> updateRoomStatus(String roomId, String status) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'status': status,
    });
  }
}
