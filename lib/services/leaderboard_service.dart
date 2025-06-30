import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';

class LeaderboardService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getAllTimeLeaderboard(
      {int limit = 50}) async {
    final query = await _firestore
        .collection('LeaderBoard')
        .orderBy('totalScore', descending: true)
        .limit(limit)
        .get();

    List<Map<String, dynamic>> leaderboard = [];

    int rank = 1;
    for (var doc in query.docs) {
      final data = doc.data();

      leaderboard.add({
        'rank': rank,
        'userId': doc.id,
        'name': data['name'] ?? 'Unknown',
        'coins': data['coins'] ?? 0,
        'totalScore': data['totalScore'] ?? 0,
        'quizzesPlayed': data['quizzesPlayed'] ?? 0,
        'photoUrl': data['photoUrl'] ?? '',
      });
      rank++;
    }
    return leaderboard;
  }

  static Future<void> updateUserStats(
      String userId, int scoreToAdd, int coinsToAdd,
      {String? name}) async {
    try {
      final entry = await FirestoreService.getLeaderboardEntry(userId);
      int totalScore = (entry?['totalScore'] ?? 0) + scoreToAdd;
      int coins = (entry?['coins'] ?? 0) + coinsToAdd;
      int quizzesPlayed = (entry?['quizzesPlayed'] ?? 0) + 1;

      // Fetch current user profile data to ensure leaderboard stays in sync
      final profileData = await _getUserProfileData(userId);
      String userName = name ??
          (profileData['fullName']!.isNotEmpty
              ? profileData['fullName']!
              : entry?['name'] ?? '');
      String photoUrl = profileData['photoUrl']!;

      await FirestoreService.addOrUpdateLeaderboardEntry(userId, {
        'userId': userId,
        'name': userName,
        'totalScore': totalScore,
        'coins': coins,
        'quizzesPlayed': quizzesPlayed,
        'photoUrl': photoUrl,
      });

      await FirestoreService.recalculateLeaderboardRanks();

      await updateUserRankInProfile(userId);
    } catch (e) {
      debugPrint('Error updating leaderboard stats: $e');
    }
  }

  static Future<int> getUserRank(String userId) async {
    try {
      final userEntry = await FirestoreService.getLeaderboardEntry(userId);
      if (userEntry == null) {
        return 0;
      }

      final userScore = userEntry['totalScore'] ?? 0;

      final higherScoresQuery = await _firestore
          .collection('LeaderBoard')
          .where('totalScore', isGreaterThan: userScore)
          .get();

      return higherScoresQuery.docs.length + 1;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return 0;
    }
  }

  static Future<void> updateUserRankInProfile(String userId) async {
    try {
      final rank = await getUserRank(userId);

      await _firestore.collection('users').doc(userId).update({
        'rank': rank,
      });
    } catch (e) {
      debugPrint('Error updating user rank in profile: $e');
    }
  }

  // Helper method to sync user profile data to leaderboard
  static Future<Map<String, String>> _getUserProfileData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        return {
          'fullName': userData?['fullName'] ?? '',
          'photoUrl': userData?['photoUrl'] ?? '',
        };
      }
    } catch (e) {
      debugPrint('Error fetching user profile data: $e');
    }
    return {'fullName': '', 'photoUrl': ''};
  }

  // Method to sync a user's profile data to their leaderboard entry
  static Future<void> syncUserProfileToLeaderboard(String userId) async {
    try {
      final profileData = await _getUserProfileData(userId);
      final entry = await FirestoreService.getLeaderboardEntry(userId);

      if (entry != null) {
        await FirestoreService.addOrUpdateLeaderboardEntry(userId, {
          'userId': userId,
          'name': profileData['fullName']!.isNotEmpty
              ? profileData['fullName']!
              : entry['name'] ?? '',
          'totalScore': entry['totalScore'] ?? 0,
          'coins': entry['coins'] ?? 0,
          'quizzesPlayed': entry['quizzesPlayed'] ?? 0,
          'photoUrl': profileData['photoUrl']!,
        });
      }
    } catch (e) {
      debugPrint('Error syncing user profile to leaderboard: $e');
    }
  }
}
