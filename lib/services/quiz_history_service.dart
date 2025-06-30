import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class QuizHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add quiz to history (robust, only under user)
  static Future<void> addQuizToHistory({
    required String userId,
    required String quizId,
    required String categoryId,
    required String categoryName,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int incorrectAnswers,
    required int timeSpent,
    required int bonusPoints,
    required List<Map<String, dynamic>> userAnswers,
  }) async {
    try {
      final historyData = {
        'userId': userId,
        'quizId': quizId,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'score': score,
        'totalQuestions': totalQuestions,
        'correctAnswers': correctAnswers,
        'incorrectAnswers': incorrectAnswers,
        'timeSpent': timeSpent,
        'bonusPoints': bonusPoints,
        'userAnswers': userAnswers,
        'accuracy': (correctAnswers / totalQuestions * 100).round(),
        'timestamp': FieldValue.serverTimestamp(), // Ensure timestamp is added
        'completedAt':
            FieldValue.serverTimestamp(), // Add completedAt for consistency
      };
      await FirestoreService.addQuizHistory(userId, quizId, historyData);
    } catch (e) {
      debugPrint('Error adding quiz to history: $e');
    }
  }

  // Get user's quiz history
  static Future<List<Map<String, dynamic>>> getUserQuizHistory(
    String userId, {
    int limit = 50, // Increase default limit to get more history
    String? categoryId,
  }) async {
    try {
      // First try to get with timestamp ordering
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('timestamp', descending: true);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      QuerySnapshot snapshot;
      List<Map<String, dynamic>> quizHistory = [];

      try {
        snapshot = await query.limit(limit).get();
        quizHistory = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      } catch (timestampError) {
        // If timestamp ordering fails, try with completedAt
        debugPrint(
            'Timestamp ordering failed, trying completedAt: $timestampError');

        query = _firestore
            .collection('users')
            .doc(userId)
            .collection('quiz_history')
            .orderBy('completedAt', descending: true);

        if (categoryId != null) {
          query = query.where('categoryId', isEqualTo: categoryId);
        }

        try {
          snapshot = await query.limit(limit).get();
          quizHistory = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        } catch (completedAtError) {
          // If both fail, get all documents and sort manually
          debugPrint(
              'CompletedAt ordering failed, getting all docs: $completedAtError');

          Query fallbackQuery = _firestore
              .collection('users')
              .doc(userId)
              .collection('quiz_history');

          if (categoryId != null) {
            fallbackQuery =
                fallbackQuery.where('categoryId', isEqualTo: categoryId);
          }

          snapshot = await fallbackQuery.get();
          quizHistory = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

          // Sort manually by timestamp or completedAt
          quizHistory.sort((a, b) {
            final aTime = a['timestamp'] ?? a['completedAt'];
            final bTime = b['timestamp'] ?? b['completedAt'];

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            // Handle Timestamp objects
            DateTime aDateTime;
            DateTime bDateTime;

            if (aTime is Timestamp) {
              aDateTime = aTime.toDate();
            } else if (aTime is DateTime) {
              aDateTime = aTime;
            } else {
              return 0;
            }

            if (bTime is Timestamp) {
              bDateTime = bTime.toDate();
            } else if (bTime is DateTime) {
              bDateTime = bTime;
            } else {
              return 0;
            }

            return bDateTime.compareTo(aDateTime); // Descending order
          });

          // Apply limit after sorting
          if (quizHistory.length > limit) {
            quizHistory = quizHistory.take(limit).toList();
          }
        }
      }

      debugPrint('Retrieved ${quizHistory.length} quiz history records');
      return quizHistory;
    } catch (e) {
      debugPrint('Error fetching quiz history: $e');
      return [];
    }
  }

  // Get user's quiz statistics
  static Future<Map<String, dynamic>> getUserQuizStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'totalQuizzes': 0,
          'totalScore': 0,
          'averageScore': 0,
          'averageAccuracy': 0,
          'totalTimeSpent': 0,
          'bestScore': 0,
          'categoriesPlayed': 0,
          'streakCount': 0,
        };
      }

      int totalQuizzes = snapshot.docs.length;
      int totalScore = 0;
      int totalCorrectAnswers = 0;
      int totalQuestions = 0;
      int totalTimeSpent = 0;
      int bestScore = 0;
      Set<String> categoriesPlayed = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalScore += (data['score'] ?? 0) as int;
        totalCorrectAnswers += (data['correctAnswers'] ?? 0) as int;
        totalQuestions += (data['totalQuestions'] ?? 0) as int;
        totalTimeSpent += (data['timeSpent'] ?? 0) as int;

        int quizScore = (data['score'] ?? 0) as int;
        if (quizScore > bestScore) {
          bestScore = quizScore;
        }

        if (data['categoryId'] != null) {
          categoriesPlayed.add(data['categoryId']);
        }
      }

      double averageScore = totalQuizzes > 0 ? totalScore / totalQuizzes : 0;
      double averageAccuracy =
          totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions * 100) : 0;

      // Calculate current streak
      int streakCount = await _calculateCurrentStreak(userId);

      return {
        'totalQuizzes': totalQuizzes,
        'totalScore': totalScore,
        'averageScore': averageScore.round(),
        'averageAccuracy': averageAccuracy.round(),
        'totalTimeSpent': totalTimeSpent,
        'bestScore': bestScore,
        'categoriesPlayed': categoriesPlayed.length,
        'streakCount': streakCount,
      };
    } catch (e) {
      debugPrint('Error fetching quiz stats: $e');
      return {};
    }
  }

  // Calculate current streak
  static Future<int> _calculateCurrentStreak(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true)
          .limit(30)
          .get();

      int streak = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final accuracy = data['accuracy'] ?? 0;

        // Consider a quiz as "successful" if accuracy is 60% or higher
        if (accuracy >= 60) {
          streak++;
        } else {
          break; // Streak broken
        }
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  // Get quiz history by category
  static Future<Map<String, dynamic>> getCategoryStats(
      String userId, String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'quizzesPlayed': 0,
          'averageScore': 0,
          'averageAccuracy': 0,
          'bestScore': 0,
          'totalTimeSpent': 0,
        };
      }

      int totalScore = 0;
      int totalCorrectAnswers = 0;
      int totalQuestions = 0;
      int totalTimeSpent = 0;
      int bestScore = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalScore += (data['score'] ?? 0) as int;
        totalCorrectAnswers += (data['correctAnswers'] ?? 0) as int;
        totalQuestions += (data['totalQuestions'] ?? 0) as int;
        totalTimeSpent += (data['timeSpent'] ?? 0) as int;

        int quizScore = (data['score'] ?? 0) as int;
        if (quizScore > bestScore) {
          bestScore = quizScore;
        }
      }

      return {
        'quizzesPlayed': snapshot.docs.length,
        'averageScore': snapshot.docs.isNotEmpty
            ? (totalScore / snapshot.docs.length).round()
            : 0,
        'averageAccuracy': totalQuestions > 0
            ? (totalCorrectAnswers / totalQuestions * 100).round()
            : 0,
        'bestScore': bestScore,
        'totalTimeSpent': totalTimeSpent,
      };
    } catch (e) {
      debugPrint('Error fetching category stats: $e');
      return {};
    }
  }

  // Get recent quiz for replay
  static Future<Map<String, dynamic>?> getQuizForReplay(
      String userId, String historyId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .doc(historyId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching quiz for replay: $e');
      return null;
    }
  }
}
