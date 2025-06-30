import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum AchievementType {
  quizCount,
  perfectScore,
  streak,
  category,
  speed,
  coins,
  rank,
  accuracy,
  timeSpent,
  special
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementType type;
  final int targetValue;
  final int coinReward;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final String rarity; // bronze, silver, gold, diamond, legend

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.targetValue,
    required this.coinReward,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.rarity = 'bronze',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type.toString(),
      'targetValue': targetValue,
      'coinReward': coinReward,
      'color': color.value,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'progress': progress,
      'rarity': rarity,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.quizCount,
      ),
      targetValue: json['targetValue'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      color: Color(json['color'] ?? Colors.blue.value),
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
          : null,
      progress: json['progress'] ?? 0,
      rarity: json['rarity'] ?? 'bronze',
    );
  }

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      targetValue: targetValue,
      coinReward: coinReward,
      color: color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      rarity: rarity,
    );
  }

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (progress / targetValue).clamp(0.0, 1.0);
  }
}

class AchievementsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined achievements
  static List<Achievement> get allAchievements => [
        // Quiz Count Achievements
        Achievement(
          id: 'first_quiz',
          title: 'Getting Started',
          description: 'Complete your first quiz',
          icon: '🎯',
          type: AchievementType.quizCount,
          targetValue: 1,
          coinReward: 50,
          color: Colors.green,
          rarity: 'bronze',
        ),
        Achievement(
          id: 'quiz_explorer',
          title: 'Quiz Explorer',
          description: 'Complete 5 quizzes',
          icon: '🗺️',
          type: AchievementType.quizCount,
          targetValue: 5,
          coinReward: 100,
          color: Colors.blue,
          rarity: 'bronze',
        ),
        Achievement(
          id: 'quiz_enthusiast',
          title: 'Quiz Enthusiast',
          description: 'Complete 25 quizzes',
          icon: '🔥',
          type: AchievementType.quizCount,
          targetValue: 25,
          coinReward: 300,
          color: Colors.orange,
          rarity: 'silver',
        ),
        Achievement(
          id: 'quiz_master',
          title: 'Quiz Master',
          description: 'Complete 100 quizzes',
          icon: '👑',
          type: AchievementType.quizCount,
          targetValue: 100,
          coinReward: 1000,
          color: Colors.purple,
          rarity: 'gold',
        ),

        // Perfect Score Achievements
        Achievement(
          id: 'perfect_first',
          title: 'Flawless Victory',
          description: 'Get your first perfect score',
          icon: '💯',
          type: AchievementType.perfectScore,
          targetValue: 1,
          coinReward: 200,
          color: Colors.amber,
          rarity: 'silver',
        ),
        Achievement(
          id: 'perfectionist',
          title: 'Perfectionist',
          description: 'Get 10 perfect scores',
          icon: '⭐',
          type: AchievementType.perfectScore,
          targetValue: 10,
          coinReward: 500,
          color: Colors.yellow,
          rarity: 'gold',
        ),

        // Category Achievements
        Achievement(
          id: 'science_master',
          title: 'Science Master',
          description: 'Complete 10 science quizzes',
          icon: '🔬',
          type: AchievementType.category,
          targetValue: 10,
          coinReward: 250,
          color: Colors.teal,
          rarity: 'silver',
        ),
        Achievement(
          id: 'history_buff',
          title: 'History Buff',
          description: 'Complete 10 history quizzes',
          icon: '📚',
          type: AchievementType.category,
          targetValue: 10,
          coinReward: 250,
          color: Colors.brown,
          rarity: 'silver',
        ),
        Achievement(
          id: 'sports_fan',
          title: 'Sports Fanatic',
          description: 'Complete 10 sports quizzes',
          icon: '⚽',
          type: AchievementType.category,
          targetValue: 10,
          coinReward: 250,
          color: Colors.green,
          rarity: 'silver',
        ),

        // Speed Achievements
        Achievement(
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Complete a quiz in under 2 minutes',
          icon: '⚡',
          type: AchievementType.speed,
          targetValue: 120, // 2 minutes in seconds
          coinReward: 150,
          color: Colors.red,
          rarity: 'silver',
        ),

        // Coin Achievements
        Achievement(
          id: 'coin_collector',
          title: 'Coin Collector',
          description: 'Earn 1000 total coins',
          icon: '🪙',
          type: AchievementType.coins,
          targetValue: 1000,
          coinReward: 200,
          color: Colors.amber,
          rarity: 'silver',
        ),
        Achievement(
          id: 'wealthy',
          title: 'Quiz Millionaire',
          description: 'Earn 5000 total coins',
          icon: '💰',
          type: AchievementType.coins,
          targetValue: 5000,
          coinReward: 500,
          color: Colors.green,
          rarity: 'gold',
        ),

        // Rank Achievements
        Achievement(
          id: 'top_100',
          title: 'Top 100',
          description: 'Reach top 100 on leaderboard',
          icon: '🏅',
          type: AchievementType.rank,
          targetValue: 100,
          coinReward: 300,
          color: Colors.brown,
          rarity: 'silver',
        ),
        Achievement(
          id: 'top_10',
          title: 'Elite Player',
          description: 'Reach top 10 on leaderboard',
          icon: '🏆',
          type: AchievementType.rank,
          targetValue: 10,
          coinReward: 1000,
          color: Colors.amber,
          rarity: 'gold',
        ),
        Achievement(
          id: 'champion',
          title: 'Champion',
          description: 'Reach #1 on leaderboard',
          icon: '👑',
          type: AchievementType.rank,
          targetValue: 1,
          coinReward: 2000,
          color: Colors.purple,
          rarity: 'legend',
        ),

        // Accuracy Achievements
        Achievement(
          id: 'sharpshooter',
          title: 'Sharpshooter',
          description: 'Maintain 90% accuracy over 10 quizzes',
          icon: '🎯',
          type: AchievementType.accuracy,
          targetValue: 90,
          coinReward: 400,
          color: Colors.indigo,
          rarity: 'gold',
        ),

        // Special Achievements
        Achievement(
          id: 'early_bird',
          title: 'Early Bird',
          description: 'Complete a quiz before 8 AM',
          icon: '🌅',
          type: AchievementType.special,
          targetValue: 1,
          coinReward: 100,
          color: Colors.orange,
          rarity: 'bronze',
        ),
        Achievement(
          id: 'night_owl',
          title: 'Night Owl',
          description: 'Complete a quiz after 10 PM',
          icon: '🦉',
          type: AchievementType.special,
          targetValue: 1,
          coinReward: 100,
          color: Colors.indigo,
          rarity: 'bronze',
        ),
        Achievement(
          id: 'weekend_warrior',
          title: 'Weekend Warrior',
          description: 'Complete 5 quizzes on weekends',
          icon: '🎮',
          type: AchievementType.special,
          targetValue: 5,
          coinReward: 200,
          color: Colors.purple,
          rarity: 'silver',
        ),
      ];

  // Get user achievements
  static Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc('progress')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return allAchievements.map((achievement) {
          final achievementData = data[achievement.id] as Map<String, dynamic>?;
          if (achievementData != null) {
            return achievement.copyWith(
              isUnlocked: achievementData['isUnlocked'] ?? false,
              unlockedAt: achievementData['unlockedAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                      achievementData['unlockedAt'])
                  : null,
              progress: achievementData['progress'] ?? 0,
            );
          }
          return achievement;
        }).toList();
      }

      return allAchievements;
    } catch (e) {
      debugPrint('Error getting user achievements: $e');
      return allAchievements;
    }
  }

  // Update user achievement progress
  static Future<List<Achievement>> updateAchievementProgress(
    String userId,
    Map<String, dynamic> userStats,
    Map<String, dynamic> quizData,
  ) async {
    try {
      // First, get current user cumulative stats from Firestore
      final userCumulativeStats = await _getUserCumulativeStats(userId);

      // Update cumulative stats with new quiz data
      final updatedStats =
          _updateCumulativeStats(userCumulativeStats, userStats, quizData);

      // Save updated cumulative stats
      await _saveCumulativeStats(userId, updatedStats);

      final currentAchievements = await getUserAchievements(userId);
      final newlyUnlocked = <Achievement>[];
      final Map<String, Map<String, dynamic>> updates = {};

      for (final achievement in currentAchievements) {
        if (achievement.isUnlocked) continue;

        int newProgress =
            _calculateProgress(achievement, updatedStats, quizData);
        bool shouldUnlock = newProgress >= achievement.targetValue;

        if (shouldUnlock && !achievement.isUnlocked) {
          // Achievement unlocked!
          newlyUnlocked.add(achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            progress: achievement.targetValue,
          ));

          updates[achievement.id] = {
            'isUnlocked': true,
            'unlockedAt': DateTime.now().millisecondsSinceEpoch,
            'progress': achievement.targetValue,
          };

          // Award coins
          await _awardCoins(userId, achievement.coinReward);
        } else if (newProgress != achievement.progress) {
          updates[achievement.id] = {
            'isUnlocked': achievement.isUnlocked,
            'progress': newProgress,
          };
        }
      }

      // Save updates to Firestore
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc('progress')
            .set(updates, SetOptions(merge: true));
      }

      return newlyUnlocked;
    } catch (e) {
      debugPrint('Error updating achievement progress: $e');
      return [];
    }
  }

  // Get user cumulative stats for achievements
  static Future<Map<String, dynamic>> _getUserCumulativeStats(
      String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc('cumulative_stats')
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }

      // Initialize default cumulative stats
      return {
        'totalQuizzesPlayed': 0,
        'totalPerfectScores': 0,
        'totalCoinsEarned': 0,
        'bestRank': 999999,
        'totalAccuracySum': 0,
        'accuracyCount': 0,
        'scienceQuizzes': 0,
        'historyQuizzes': 0,
        'sportsQuizzes': 0,
        'musicQuizzes': 0,
        'moviesQuizzes': 0,
        'mathsQuizzes': 0,
        'physicsQuizzes': 0,
        'weekendQuizzes': 0,
        'earlyBirdQuizzes': 0,
        'nightOwlQuizzes': 0,
        'speedDemonAchieved': false,
      };
    } catch (e) {
      debugPrint('Error getting cumulative stats: $e');
      return {};
    }
  }

  // Update cumulative stats with new quiz data
  static Map<String, dynamic> _updateCumulativeStats(
    Map<String, dynamic> currentStats,
    Map<String, dynamic> userStats,
    Map<String, dynamic> quizData,
  ) {
    final updated = Map<String, dynamic>.from(currentStats);

    // Update basic counters
    updated['totalQuizzesPlayed'] = (updated['totalQuizzesPlayed'] ?? 0) + 1;

    // Update perfect scores
    if (quizData['isPerfectScore'] == true) {
      updated['totalPerfectScores'] = (updated['totalPerfectScores'] ?? 0) + 1;
    }

    // Update total coins earned (from quiz results)
    final coinsFromQuiz = userStats['coinsEarned'] ?? 0;
    updated['totalCoinsEarned'] =
        (updated['totalCoinsEarned'] ?? 0) + coinsFromQuiz;

    // Update best rank
    final currentRank = userStats['rank'] ?? 999999;
    updated['bestRank'] = currentRank < (updated['bestRank'] ?? 999999)
        ? currentRank
        : updated['bestRank'];

    // Update accuracy tracking
    final accuracy = userStats['averageAccuracy'] ?? 0;
    updated['totalAccuracySum'] = (updated['totalAccuracySum'] ?? 0) + accuracy;
    updated['accuracyCount'] = (updated['accuracyCount'] ?? 0) + 1;

    // Update category-specific counters
    final categoryName =
        quizData['categoryName']?.toString().toLowerCase() ?? '';
    if (categoryName.isNotEmpty) {
      final categoryKey = '${categoryName}Quizzes';
      updated[categoryKey] = (updated[categoryKey] ?? 0) + 1;
    }

    // Update special achievement tracking
    final now = DateTime.now();
    if (now.weekday >= 6) {
      // Weekend
      updated['weekendQuizzes'] = (updated['weekendQuizzes'] ?? 0) + 1;
    }

    if (now.hour < 8) {
      // Early bird
      updated['earlyBirdQuizzes'] = (updated['earlyBirdQuizzes'] ?? 0) + 1;
    }

    if (now.hour >= 22) {
      // Night owl
      updated['nightOwlQuizzes'] = (updated['nightOwlQuizzes'] ?? 0) + 1;
    }

    // Speed demon check
    final timeSpent = quizData['timeSpent'] ?? 999999;
    if (timeSpent <= 120) {
      // 2 minutes
      updated['speedDemonAchieved'] = true;
    }

    return updated;
  }

  // Save cumulative stats
  static Future<void> _saveCumulativeStats(
      String userId, Map<String, dynamic> stats) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc('cumulative_stats')
          .set(stats, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving cumulative stats: $e');
    }
  }

  static int _calculateProgress(
    Achievement achievement,
    Map<String, dynamic> cumulativeStats,
    Map<String, dynamic> quizData,
  ) {
    switch (achievement.type) {
      case AchievementType.quizCount:
        return cumulativeStats['totalQuizzesPlayed'] ?? 0;

      case AchievementType.perfectScore:
        return cumulativeStats['totalPerfectScores'] ?? 0;

      case AchievementType.coins:
        return cumulativeStats['totalCoinsEarned'] ?? 0;

      case AchievementType.rank:
        final bestRank = cumulativeStats['bestRank'] ?? 999999;
        return bestRank <= achievement.targetValue
            ? achievement.targetValue
            : 0;

      case AchievementType.speed:
        return cumulativeStats['speedDemonAchieved'] == true
            ? achievement.targetValue
            : 0;

      case AchievementType.accuracy:
        final totalAccuracy = cumulativeStats['totalAccuracySum'] ?? 0;
        final count = cumulativeStats['accuracyCount'] ?? 0;
        if (count >= 10) {
          // Need at least 10 quizzes for accuracy achievement
          final averageAccuracy = totalAccuracy / count;
          return averageAccuracy >= achievement.targetValue
              ? achievement.targetValue
              : averageAccuracy.round();
        }
        return 0;

      case AchievementType.category:
        final categoryName = _extractCategoryFromAchievementId(achievement.id);
        final categoryKey = '${categoryName}Quizzes';
        return cumulativeStats[categoryKey] ?? 0;

      case AchievementType.special:
        return _calculateSpecialProgress(achievement, cumulativeStats);

      default:
        return 0;
    }
  }

  static String _extractCategoryFromAchievementId(String achievementId) {
    // Extract category name from achievement ID
    switch (achievementId) {
      case 'science_master':
        return 'science';
      case 'history_buff':
        return 'history';
      case 'sports_fan':
        return 'sports';
      default:
        return achievementId.split('_')[0];
    }
  }

  static int _calculateSpecialProgress(
    Achievement achievement,
    Map<String, dynamic> cumulativeStats,
  ) {
    switch (achievement.id) {
      case 'early_bird':
        return cumulativeStats['earlyBirdQuizzes'] ?? 0;
      case 'night_owl':
        return cumulativeStats['nightOwlQuizzes'] ?? 0;
      case 'weekend_warrior':
        return cumulativeStats['weekendQuizzes'] ?? 0;
      default:
        return 0;
    }
  }

  static Future<void> _awardCoins(String userId, int coins) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'coins': FieldValue.increment(coins),
      });
    } catch (e) {
      debugPrint('Error awarding coins: $e');
    }
  }

  // Get achievement statistics for user
  static Future<Map<String, int>> getAchievementStats(String userId) async {
    try {
      final achievements = await getUserAchievements(userId);
      final unlockedCount = achievements.where((a) => a.isUnlocked).length;
      final totalCoinsEarned = achievements
          .where((a) => a.isUnlocked)
          .fold(0, (sum, a) => sum + a.coinReward);

      return {
        'total': achievements.length,
        'unlocked': unlockedCount,
        'coinsEarned': totalCoinsEarned,
      };
    } catch (e) {
      debugPrint('Error getting achievement stats: $e');
      return {'total': 0, 'unlocked': 0, 'coinsEarned': 0};
    }
  }

  // Method to retroactively check and unlock achievements for existing users
  static Future<List<Achievement>> checkAndUnlockRetroactiveAchievements(
      String userId) async {
    try {
      // Get user's current profile data
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data()!;
      final currentCoins = userData['coins'] ?? 0;
      final currentQuizzesPlayed = userData['quizzesPlayed'] ?? 0;

      // Get user's quiz history to calculate more detailed stats
      final historyQuery = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .get();

      // Calculate retroactive stats from quiz history
      int perfectScores = 0;
      double totalAccuracy = 0;
      Map<String, int> categoryQuizzes = {};
      int weekendQuizzes = 0;
      int earlyBirdQuizzes = 0;
      int nightOwlQuizzes = 0;
      bool speedAchieved = false;

      for (final doc in historyQuery.docs) {
        final data = doc.data();
        final accuracy = data['accuracy'] ?? 0;
        final categoryName =
            data['categoryName']?.toString().toLowerCase() ?? '';
        final timeSpent = data['timeSpent'] ?? 999999;
        final timestamp = data['timestamp'] as Timestamp?;

        // Count perfect scores
        if (accuracy == 100) perfectScores++;

        totalAccuracy += accuracy;

        // Count category quizzes
        if (categoryName.isNotEmpty) {
          categoryQuizzes[categoryName] =
              (categoryQuizzes[categoryName] ?? 0) + 1;
        }

        // Check speed achievement
        if (timeSpent <= 120) speedAchieved = true;

        // Check special time-based achievements (if timestamp available)
        if (timestamp != null) {
          final dateTime = timestamp.toDate();
          if (dateTime.weekday >= 6) weekendQuizzes++;
          if (dateTime.hour < 8) earlyBirdQuizzes++;
          if (dateTime.hour >= 22) nightOwlQuizzes++;
        }
      }

      // Get current rank
      final rank = await getUserRank(userId);

      // Create comprehensive cumulative stats
      final cumulativeStats = {
        'totalQuizzesPlayed': currentQuizzesPlayed,
        'totalPerfectScores': perfectScores,
        'totalCoinsEarned': currentCoins,
        'bestRank': rank,
        'totalAccuracySum': totalAccuracy.round(),
        'accuracyCount': historyQuery.docs.length,
        'scienceQuizzes': categoryQuizzes['science'] ?? 0,
        'historyQuizzes': categoryQuizzes['history'] ?? 0,
        'sportsQuizzes': categoryQuizzes['sports'] ?? 0,
        'musicQuizzes': categoryQuizzes['music'] ?? 0,
        'moviesQuizzes': categoryQuizzes['movies'] ?? 0,
        'mathsQuizzes': categoryQuizzes['maths'] ?? 0,
        'physicsQuizzes': categoryQuizzes['physics'] ?? 0,
        'weekendQuizzes': weekendQuizzes,
        'earlyBirdQuizzes': earlyBirdQuizzes,
        'nightOwlQuizzes': nightOwlQuizzes,
        'speedDemonAchieved': speedAchieved,
      };

      // Save cumulative stats
      await _saveCumulativeStats(userId, cumulativeStats);

      // Check all achievements
      final currentAchievements = await getUserAchievements(userId);
      final newlyUnlocked = <Achievement>[];
      final Map<String, Map<String, dynamic>> updates = {};

      for (final achievement in currentAchievements) {
        if (achievement.isUnlocked) continue;

        int progress = _calculateProgress(achievement, cumulativeStats, {});
        bool shouldUnlock = progress >= achievement.targetValue;

        if (shouldUnlock) {
          newlyUnlocked.add(achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            progress: achievement.targetValue,
          ));

          updates[achievement.id] = {
            'isUnlocked': true,
            'unlockedAt': DateTime.now().millisecondsSinceEpoch,
            'progress': achievement.targetValue,
          };

          // Award coins
          await _awardCoins(userId, achievement.coinReward);
        } else {
          updates[achievement.id] = {
            'isUnlocked': false,
            'progress': progress,
          };
        }
      }

      // Save updates
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc('progress')
            .set(updates, SetOptions(merge: true));
      }

      return newlyUnlocked;
    } catch (e) {
      debugPrint('Error checking retroactive achievements: $e');
      return [];
    }
  }

  // Helper method to get current rank (reusing logic from LeaderboardService)
  static Future<int> getUserRank(String userId) async {
    try {
      final userEntry =
          await _firestore.collection('LeaderBoard').doc(userId).get();
      if (!userEntry.exists) return 999999;

      final userScore = userEntry.data()?['totalScore'] ?? 0;
      final higherScoresQuery = await _firestore
          .collection('LeaderBoard')
          .where('totalScore', isGreaterThan: userScore)
          .get();

      return higherScoresQuery.docs.length + 1;
    } catch (e) {
      debugPrint('Error getting user rank: $e');
      return 999999;
    }
  }
}
