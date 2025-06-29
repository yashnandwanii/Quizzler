import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/model/quiz_history_model.dart';

class QuizHistoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add quiz to history
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
        'completedAt': FieldValue.serverTimestamp(),
        'accuracy': (correctAnswers / totalQuestions * 100).round(),
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .add(historyData);

      // Also add to global quiz history for analytics
      await _firestore.collection('quiz_history').add(historyData);
    } catch (e) {
      print('Error adding quiz to history: $e');
    }
  }

  // Get user's quiz history
  static Future<List<Map<String, dynamic>>> getUserQuizHistory(
    String userId, {
    int limit = 20,
    String? categoryId,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true);

      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final snapshot = await query.limit(limit).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching quiz history: $e');
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
      double averageAccuracy = totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions * 100) : 0;

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
      print('Error fetching quiz stats: $e');
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
      print('Error calculating streak: $e');
      return 0;
    }
  }

  // Get quiz history by category
  static Future<Map<String, dynamic>> getCategoryStats(String userId, String categoryId) async {
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
        'averageScore': snapshot.docs.length > 0 ? (totalScore / snapshot.docs.length).round() : 0,
        'averageAccuracy': totalQuestions > 0 ? (totalCorrectAnswers / totalQuestions * 100).round() : 0,
        'bestScore': bestScore,
        'totalTimeSpent': totalTimeSpent,
      };
    } catch (e) {
      print('Error fetching category stats: $e');
      return {};
    }
  }

  // Get recent quiz for replay
  static Future<Map<String, dynamic>?> getQuizForReplay(String userId, String historyId) async {
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
      print('Error fetching quiz for replay: $e');
      return null;
    }
  }
}