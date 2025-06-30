import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int targetValue;
  final int coinReward;
  final Color color;
  final String type; // 'quiz_count', 'category', 'accuracy', 'speed'
  final DateTime date;
  final bool isCompleted;
  final int progress;

  DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.targetValue,
    required this.coinReward,
    required this.color,
    required this.type,
    required this.date,
    this.isCompleted = false,
    this.progress = 0,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🎯',
      targetValue: json['targetValue'] ?? 1,
      coinReward: json['coinReward'] ?? 50,
      color: Color(json['color'] ?? Colors.blue.value),
      type: json['type'] ?? 'quiz_count',
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      isCompleted: json['isCompleted'] ?? false,
      progress: json['progress'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'targetValue': targetValue,
      'coinReward': coinReward,
      'color': color.value,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'progress': progress,
    };
  }

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (progress / targetValue).clamp(0.0, 1.0);
  }
}

class DailyChallengeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate daily challenges
  static List<DailyChallenge> generateDailyChallenges(DateTime date) {
    final dayOfWeek = date.weekday;
    final challenges = <DailyChallenge>[];

    // Base challenge: Complete quizzes
    challenges.add(DailyChallenge(
      id: 'daily_quiz_${date.day}',
      title: 'Quiz Master',
      description: 'Complete ${_getQuizTarget(dayOfWeek)} quizzes today',
      icon: '🎯',
      targetValue: _getQuizTarget(dayOfWeek),
      coinReward: _getQuizTarget(dayOfWeek) * 25,
      color: Colors.blue,
      type: 'quiz_count',
      date: date,
    ));

    // Weekend special challenges
    if (dayOfWeek >= 6) {
      challenges.add(DailyChallenge(
        id: 'weekend_warrior_${date.day}',
        title: 'Weekend Warrior',
        description: 'Score 80% or higher in any quiz',
        icon: '🏆',
        targetValue: 80,
        coinReward: 100,
        color: Colors.amber,
        type: 'accuracy',
        date: date,
      ));
    }

    // Category-specific challenges (rotate daily)
    final categories = ['Science', 'History', 'Sports', 'Music', 'Movies'];
    final categoryIndex = date.day % categories.length;
    challenges.add(DailyChallenge(
      id: 'category_${categories[categoryIndex].toLowerCase()}_${date.day}',
      title: '${categories[categoryIndex]} Expert',
      description: 'Complete a ${categories[categoryIndex]} quiz',
      icon: _getCategoryIcon(categories[categoryIndex]),
      targetValue: 1,
      coinReward: 75,
      color: _getCategoryColor(categories[categoryIndex]),
      type: 'category',
      date: date,
    ));

    // Speed challenge (mid-week)
    if (dayOfWeek >= 2 && dayOfWeek <= 4) {
      challenges.add(DailyChallenge(
        id: 'speed_demon_${date.day}',
        title: 'Speed Demon',
        description: 'Complete a quiz in under 3 minutes',
        icon: '⚡',
        targetValue: 180, // 3 minutes in seconds
        coinReward: 150,
        color: Colors.orange,
        type: 'speed',
        date: date,
      ));
    }

    return challenges;
  }

  static int _getQuizTarget(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1: // Monday
        return 2;
      case 6: // Saturday
      case 7: // Sunday
        return 3;
      default:
        return 1;
    }
  }

  static String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return '🔬';
      case 'history':
        return '📚';
      case 'sports':
        return '⚽';
      case 'music':
        return '🎵';
      case 'movies':
        return '🎬';
      default:
        return '🎯';
    }
  }

  static Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'science':
        return Colors.teal;
      case 'history':
        return Colors.brown;
      case 'sports':
        return Colors.green;
      case 'music':
        return Colors.purple;
      case 'movies':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  // Get user's daily challenges
  static Future<List<DailyChallenge>> getUserDailyChallenges(
      String userId) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .doc(todayStr)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final challengesData = data['challenges'] as List<dynamic>? ?? [];
        return challengesData
            .map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
            .toList();
      } else {
        // Generate new challenges for today
        final challenges = generateDailyChallenges(today);
        await _saveDailyChallenges(userId, challenges);
        return challenges;
      }
    } catch (e) {
      debugPrint('Error getting daily challenges: $e');
      return generateDailyChallenges(DateTime.now());
    }
  }

  // Save daily challenges
  static Future<void> _saveDailyChallenges(
      String userId, List<DailyChallenge> challenges) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .doc(todayStr)
          .set({
        'date': today.millisecondsSinceEpoch,
        'challenges': challenges.map((c) => c.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error saving daily challenges: $e');
    }
  }

  // Update challenge progress
  static Future<List<DailyChallenge>> updateChallengeProgress(
    String userId,
    Map<String, dynamic> quizData,
  ) async {
    try {
      final challenges = await getUserDailyChallenges(userId);
      final completedChallenges = <DailyChallenge>[];
      bool hasUpdates = false;

      for (int i = 0; i < challenges.length; i++) {
        final challenge = challenges[i];
        if (challenge.isCompleted) continue;

        int newProgress = _calculateChallengeProgress(challenge, quizData);
        bool shouldComplete = false;

        switch (challenge.type) {
          case 'quiz_count':
            newProgress = challenge.progress + 1;
            shouldComplete = newProgress >= challenge.targetValue;
            break;
          case 'accuracy':
            final accuracy = quizData['accuracy'] ?? 0;
            if (accuracy >= challenge.targetValue) {
              newProgress = challenge.targetValue;
              shouldComplete = true;
            }
            break;
          case 'category':
            final categoryName = quizData['categoryName'] ?? '';
            if (challenge.description
                .toLowerCase()
                .contains(categoryName.toLowerCase())) {
              newProgress = challenge.targetValue;
              shouldComplete = true;
            }
            break;
          case 'speed':
            final timeSpent = quizData['timeSpent'] ?? 999999;
            if (timeSpent <= challenge.targetValue) {
              newProgress = challenge.targetValue;
              shouldComplete = true;
            }
            break;
        }

        if (newProgress != challenge.progress || shouldComplete) {
          challenges[i] = DailyChallenge(
            id: challenge.id,
            title: challenge.title,
            description: challenge.description,
            icon: challenge.icon,
            targetValue: challenge.targetValue,
            coinReward: challenge.coinReward,
            color: challenge.color,
            type: challenge.type,
            date: challenge.date,
            isCompleted: shouldComplete,
            progress: shouldComplete ? challenge.targetValue : newProgress,
          );
          hasUpdates = true;

          if (shouldComplete) {
            completedChallenges.add(challenges[i]);
            // Award coins
            await _firestore.collection('users').doc(userId).update({
              'coins': FieldValue.increment(challenge.coinReward),
            });
          }
        }
      }

      if (hasUpdates) {
        await _saveDailyChallenges(userId, challenges);
      }

      return completedChallenges;
    } catch (e) {
      debugPrint('Error updating challenge progress: $e');
      return [];
    }
  }

  static int _calculateChallengeProgress(
    DailyChallenge challenge,
    Map<String, dynamic> quizData,
  ) {
    switch (challenge.type) {
      case 'quiz_count':
        return challenge.progress + 1;
      case 'accuracy':
        final accuracy = quizData['accuracy'] ?? 0;
        return accuracy >= challenge.targetValue
            ? challenge.targetValue
            : challenge.progress;
      case 'category':
        final categoryName = quizData['categoryName'] ?? '';
        return challenge.description
                .toLowerCase()
                .contains(categoryName.toLowerCase())
            ? challenge.targetValue
            : challenge.progress;
      case 'speed':
        final timeSpent = quizData['timeSpent'] ?? 999999;
        return timeSpent <= challenge.targetValue
            ? challenge.targetValue
            : challenge.progress;
      default:
        return challenge.progress;
    }
  }

  // Get challenge completion stats
  static Future<Map<String, int>> getChallengeStats(String userId) async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('daily_challenges')
          .doc(todayStr)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final challengesData = data['challenges'] as List<dynamic>? ?? [];
        final challenges = challengesData
            .map((c) => DailyChallenge.fromJson(c as Map<String, dynamic>))
            .toList();

        final completed = challenges.where((c) => c.isCompleted).length;
        final totalCoins = challenges
            .where((c) => c.isCompleted)
            .fold(0, (sum, c) => sum + c.coinReward);

        return {
          'total': challenges.length,
          'completed': completed,
          'coinsEarned': totalCoins,
        };
      }

      return {'total': 0, 'completed': 0, 'coinsEarned': 0};
    } catch (e) {
      debugPrint('Error getting challenge stats: $e');
      return {'total': 0, 'completed': 0, 'coinsEarned': 0};
    }
  }
}
