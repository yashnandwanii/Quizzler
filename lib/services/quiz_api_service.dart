import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizApiService {
  static const String baseUrl = "https://quizapi.io/api/v1/questions";
  static final String apiKey = dotenv.env['QUIZ_API_KEY'] ?? '';

  static Future<List<QuizModel>> fetchQuizzes({
    String? category,
    String? difficulty,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "apiKey": apiKey,
        "limit": limit.toString(),
        if (category != null) "category": category,
        if (difficulty != null) "difficulty": difficulty,
      });

      final response = await http.get(uri);
      debugPrint("response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final quizzes = jsonData.map((e) => QuizModel.fromJson(e)).toList();
        return quizzes;
      } else {
        throw Exception("Failed to load quizzes: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching quizzes: $e");
      rethrow;
    }
  }

  static Future<List<QuizModel>> fetchRandomQuizzes({
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "apiKey": apiKey,
        "limit": limit.toString(),
        "random": "true",
      });

      final response = await http.get(uri);
      debugPrint("response: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final quizzes = jsonData.map((e) => QuizModel.fromJson(e)).toList();
        return quizzes;
      } else {
        throw Exception("Failed to load quizzes: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching quizzes: $e");
      rethrow;
    }
  }
}

class QuizScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save quiz score to Firebase
  static Future<void> saveQuizScore(QuizScore score) async {
    try {
      await _firestore.collection('quiz_scores').add(score.toJson());

      // Update user's total coins and total score
      await _firestore.collection('users').doc(score.userId).update({
        'coins': FieldValue.increment(score.coinsEarned),
        'totalScore': FieldValue.increment(score.totalScore),
      });
    } catch (e) {
      debugPrint('Error saving quiz score: $e');
      throw Exception('Failed to save quiz score');
    }
  }

  // Get leaderboard data (weekly or all-time)
  static Future<List<QuizScore>> getLeaderboard({bool isWeekly = false}) async {
    try {
      Query query = _firestore.collection('quiz_scores');

      if (isWeekly) {
        // Get scores from the last 7 days
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        query = query.where('timestamp',
            isGreaterThan: weekAgo.millisecondsSinceEpoch);
      }

      final querySnapshot = await query
          .orderBy('totalScore', descending: true)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => QuizScore.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      throw Exception('Failed to fetch leaderboard');
    }
  }

  // Get user's best score
  static Future<QuizScore?> getUserBestScore(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('quiz_scores')
          .where('userId', isEqualTo: userId)
          .orderBy('totalScore', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return QuizScore.fromJson(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user best score: $e');
      return null;
    }
  }

  // Get user's rank
  static Future<int> getUserRank(String userId) async {
    try {
      final userScore = await getUserBestScore(userId);
      if (userScore == null) return -1;

      final querySnapshot = await _firestore
          .collection('quiz_scores')
          .where('totalScore', isGreaterThan: userScore.totalScore)
          .get();

      return querySnapshot.docs.length + 1;
    } catch (e) {
      debugPrint('Error fetching user rank: $e');
      return -1;
    }
  }
}
