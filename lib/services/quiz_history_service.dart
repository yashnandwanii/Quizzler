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
        'isRevisionQuiz': false, // Mark as regular quiz for streak calculation
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

      // Calculate additional streak stats
      Map<String, dynamic> streakStats = await _getStreakStatistics(userId);

      return {
        'totalQuizzes': totalQuizzes,
        'totalScore': totalScore,
        'averageScore': averageScore.round(),
        'averageAccuracy': averageAccuracy.round(),
        'totalTimeSpent': totalTimeSpent,
        'bestScore': bestScore,
        'categoriesPlayed': categoriesPlayed.length,
        'streakCount': streakCount,
        'longestStreak': streakStats['longestStreak'] ?? 0,
        'streaksThisWeek': streakStats['streaksThisWeek'] ?? 0,
        'streaksThisMonth': streakStats['streaksThisMonth'] ?? 0,
      };
    } catch (e) {
      debugPrint('Error fetching quiz stats: $e');
      return {};
    }
  }

  // Calculate current streak with enhanced logic
  static Future<int> _calculateCurrentStreak(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true)
          .limit(100) // Get more history for better streak calculation
          .get();

      if (snapshot.docs.isEmpty) return 0;

      // Group quizzes by day
      Map<String, List<Map<String, dynamic>>> quizzesByDay = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = data['completedAt'];

        if (completedAt == null) continue;

        DateTime date;
        if (completedAt is Timestamp) {
          date = completedAt.toDate();
        } else if (completedAt is DateTime) {
          date = completedAt;
        } else {
          continue;
        }

        // Format date as YYYY-MM-DD for grouping
        String dayKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        if (!quizzesByDay.containsKey(dayKey)) {
          quizzesByDay[dayKey] = [];
        }

        quizzesByDay[dayKey]!.add(data);
      }

      // Sort days in descending order (most recent first)
      List<String> sortedDays = quizzesByDay.keys.toList()
        ..sort((a, b) => b.compareTo(a));

      int currentStreak = 0;
      DateTime today = DateTime.now();

      for (String dayKey in sortedDays) {
        DateTime dayDate = DateTime.parse(dayKey);
        List<Map<String, dynamic>> dayQuizzes = quizzesByDay[dayKey]!;

        // Check if this day should count towards streak
        bool daySuccess = _isDaySuccessful(dayQuizzes);

        if (daySuccess) {
          // Check if this is consecutive day
          if (currentStreak == 0) {
            // First day of streak - must be today or yesterday
            int daysDifference = today.difference(dayDate).inDays;
            if (daysDifference <= 1) {
              currentStreak = 1;
            } else {
              break; // Gap in streak
            }
          } else {
            // Check if consecutive day
            DateTime previousDay =
                DateTime.parse(sortedDays[sortedDays.indexOf(dayKey) - 1]);
            if (previousDay.difference(dayDate).inDays == 1) {
              currentStreak++;
            } else {
              break; // Gap in consecutive days
            }
          }
        } else {
          break; // Day was not successful, streak broken
        }
      }

      return currentStreak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  // Determine if a day is considered successful for streak calculation
  static bool _isDaySuccessful(List<Map<String, dynamic>> dayQuizzes) {
    if (dayQuizzes.isEmpty) return false;

    // Calculate day's overall performance
    int totalCorrect = 0;
    int totalQuestions = 0;
    int totalQuizzes = dayQuizzes.length;

    for (var quiz in dayQuizzes) {
      totalCorrect += (quiz['correctAnswers'] ?? 0) as int;
      totalQuestions += (quiz['totalQuestions'] ?? 0) as int;
    }

    double dayAccuracy =
        totalQuestions > 0 ? (totalCorrect / totalQuestions * 100) : 0;

    // Criteria for successful day:
    // 1. At least 1 quiz completed
    // 2. Overall accuracy >= 70% OR at least 2 quizzes with average accuracy >= 60%
    if (totalQuizzes == 1) {
      return dayAccuracy >= 70;
    } else {
      return dayAccuracy >= 60; // More lenient for multiple quizzes
    }
  }

  // Get additional streak statistics
  static Future<Map<String, dynamic>> _getStreakStatistics(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('completedAt', descending: true)
          .limit(365) // Get last year of data
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'longestStreak': 0,
          'streaksThisWeek': 0,
          'streaksThisMonth': 0,
        };
      }

      // Group quizzes by day
      Map<String, List<Map<String, dynamic>>> quizzesByDay = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final completedAt = data['completedAt'];

        if (completedAt == null) continue;

        DateTime date;
        if (completedAt is Timestamp) {
          date = completedAt.toDate();
        } else if (completedAt is DateTime) {
          date = completedAt;
        } else {
          continue;
        }

        String dayKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        if (!quizzesByDay.containsKey(dayKey)) {
          quizzesByDay[dayKey] = [];
        }

        quizzesByDay[dayKey]!.add(data);
      }

      // Calculate longest streak ever
      int longestStreak = 0;
      int currentCalculatedStreak = 0;

      List<String> allDays = quizzesByDay.keys.toList()..sort();

      for (int i = 0; i < allDays.length; i++) {
        String dayKey = allDays[i];
        bool daySuccess = _isDaySuccessful(quizzesByDay[dayKey]!);

        if (daySuccess) {
          if (i == 0) {
            currentCalculatedStreak = 1;
          } else {
            DateTime currentDay = DateTime.parse(dayKey);
            DateTime previousDay = DateTime.parse(allDays[i - 1]);

            if (currentDay.difference(previousDay).inDays == 1) {
              currentCalculatedStreak++;
            } else {
              currentCalculatedStreak = 1;
            }
          }

          if (currentCalculatedStreak > longestStreak) {
            longestStreak = currentCalculatedStreak;
          }
        } else {
          currentCalculatedStreak = 0;
        }
      }

      // Calculate streaks this week and month
      DateTime now = DateTime.now();
      DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
      DateTime monthStart = DateTime(now.year, now.month, 1);

      int streaksThisWeek = 0;
      int streaksThisMonth = 0;

      for (String dayKey in quizzesByDay.keys) {
        DateTime dayDate = DateTime.parse(dayKey);
        bool daySuccess = _isDaySuccessful(quizzesByDay[dayKey]!);

        if (daySuccess) {
          if (dayDate.isAfter(weekStart) ||
              dayDate.isAtSameMomentAs(weekStart)) {
            streaksThisWeek++;
          }
          if (dayDate.isAfter(monthStart) ||
              dayDate.isAtSameMomentAs(monthStart)) {
            streaksThisMonth++;
          }
        }
      }

      return {
        'longestStreak': longestStreak,
        'streaksThisWeek': streaksThisWeek,
        'streaksThisMonth': streaksThisMonth,
      };
    } catch (e) {
      debugPrint('Error calculating streak statistics: $e');
      return {
        'longestStreak': 0,
        'streaksThisWeek': 0,
        'streaksThisMonth': 0,
      };
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
