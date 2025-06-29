import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/model/user_model.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get global leaderboard
  static Future<List<Map<String, dynamic>>> getGlobalLeaderboard({
    int limit = 50,
  }) async {
    try {
      final query = await _firestore
          .collection('users')
          .orderBy('totalScore', descending: true)
          .orderBy('coins', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> leaderboard = [];
      int rank = 1;

      for (var doc in query.docs) {
        final data = doc.data();
        if (data.containsKey('profile')) {
          leaderboard.add({
            'rank': rank,
            'userId': doc.id,
            'fullName': data['profile']['fullName'] ?? 'Unknown',
            'photoUrl': data['profile']['photoUrl'] ?? '',
            'totalScore': data['totalScore'] ?? 0,
            'coins': data['coins'] ?? 0,
            'quizzesPlayed': data['quizzesPlayed'] ?? 0,
          });
          rank++;
        }
      }

      return leaderboard;
    } catch (e) {
      print('Error fetching global leaderboard: $e');
      return [];
    }
  }

  // Get weekly leaderboard
  static Future<List<Map<String, dynamic>>> getWeeklyLeaderboard({
    int limit = 50,
  }) async {
    try {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      final query = await _firestore
          .collection('quiz_scores')
          .where('timestamp', isGreaterThan: weekAgo.millisecondsSinceEpoch)
          .orderBy('timestamp')
          .orderBy('totalScore', descending: true)
          .get();

      // Group scores by user and calculate weekly totals
      Map<String, Map<String, dynamic>> userWeeklyScores = {};

      for (var doc in query.docs) {
        final data = doc.data();
        final userId = data['userId'];
        
        if (userWeeklyScores.containsKey(userId)) {
          userWeeklyScores[userId]!['totalScore'] += data['totalScore'] ?? 0;
          userWeeklyScores[userId]!['quizzesPlayed'] += 1;
        } else {
          userWeeklyScores[userId] = {
            'userId': userId,
            'userName': data['userName'] ?? 'Unknown',
            'totalScore': data['totalScore'] ?? 0,
            'quizzesPlayed': 1,
          };
        }
      }

      // Convert to list and sort
      List<Map<String, dynamic>> weeklyLeaderboard = userWeeklyScores.values.toList();
      weeklyLeaderboard.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));

      // Add ranks and limit results
      for (int i = 0; i < weeklyLeaderboard.length && i < limit; i++) {
        weeklyLeaderboard[i]['rank'] = i + 1;
      }

      return weeklyLeaderboard.take(limit).toList();
    } catch (e) {
      print('Error fetching weekly leaderboard: $e');
      return [];
    }
  }

  // Get user's rank
  static Future<Map<String, int>> getUserRank(String userId) async {
    try {
      // Global rank
      final globalQuery = await _firestore
          .collection('users')
          .orderBy('totalScore', descending: true)
          .orderBy('coins', descending: true)
          .get();

      int globalRank = -1;
      for (int i = 0; i < globalQuery.docs.length; i++) {
        if (globalQuery.docs[i].id == userId) {
          globalRank = i + 1;
          break;
        }
      }

      // Weekly rank
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyScores = await getWeeklyLeaderboard();
      
      int weeklyRank = -1;
      for (int i = 0; i < weeklyScores.length; i++) {
        if (weeklyScores[i]['userId'] == userId) {
          weeklyRank = i + 1;
          break;
        }
      }

      return {
        'globalRank': globalRank,
        'weeklyRank': weeklyRank,
      };
    } catch (e) {
      print('Error getting user rank: $e');
      return {'globalRank': -1, 'weeklyRank': -1};
    }
  }

  // Update user's total score and stats
  static Future<void> updateUserStats(String userId, int scoreToAdd, int coinsToAdd) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'totalScore': FieldValue.increment(scoreToAdd),
        'coins': FieldValue.increment(coinsToAdd),
        'quizzesPlayed': FieldValue.increment(1),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }
}