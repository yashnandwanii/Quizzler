// Test to verify achievements system is working correctly
// You can run this by calling AchievementsService.testAchievementSystem(userId)

import 'package:wallpaper_app/services/achievements_service.dart';

class AchievementsTest {
  static Future<void> testAchievementSystem(String userId) async {
    print('🧪 Testing Achievement System...');

    try {
      // 1. Test retroactive achievement checking
      print('📊 Checking retroactive achievements...');
      final retroAchievements =
          await AchievementsService.checkAndUnlockRetroactiveAchievements(
              userId);
      print(
          '✅ Retroactive check complete: ${retroAchievements.length} achievements unlocked');

      // 2. Test getting user achievements
      print('📋 Getting user achievements...');
      final userAchievements =
          await AchievementsService.getUserAchievements(userId);
      final unlockedCount = userAchievements.where((a) => a.isUnlocked).length;
      print(
          '✅ User has $unlockedCount/${userAchievements.length} achievements unlocked');

      // 3. Test achievement stats
      print('📈 Getting achievement stats...');
      final stats = await AchievementsService.getAchievementStats(userId);
      print(
          '✅ Stats: ${stats['unlocked']}/${stats['total']} unlocked, ${stats['coinsEarned']} coins earned');

      // 4. Print unlocked achievements
      print('🏆 Unlocked Achievements:');
      for (final achievement in userAchievements.where((a) => a.isUnlocked)) {
        print(
            '   ${achievement.icon} ${achievement.title} - ${achievement.coinReward} coins');
      }

      // 5. Print achievements in progress
      print('🎯 Achievements in Progress:');
      final inProgress =
          userAchievements.where((a) => !a.isUnlocked && a.progress > 0);
      for (final achievement in inProgress) {
        final percentage = (achievement.progressPercentage * 100).toInt();
        print(
            '   ${achievement.icon} ${achievement.title} - $percentage% (${achievement.progress}/${achievement.targetValue})');
      }

      print('✅ Achievement system test completed successfully!');
    } catch (e) {
      print('❌ Achievement system test failed: $e');
    }
  }

  static Future<void> simulateQuizCompletion(String userId) async {
    print('🎮 Simulating quiz completion...');

    final userStats = {
      'rank': 50,
      'averageAccuracy': 85,
      'coinsEarned': 100,
    };

    final quizData = {
      'timeSpent': 90, // 1.5 minutes - should trigger speed achievement
      'isPerfectScore': true,
      'categoryName': 'Science',
      'accuracy': 100,
    };

    final newAchievements = await AchievementsService.updateAchievementProgress(
      userId,
      userStats,
      quizData,
    );

    print(
        '🎉 Quiz completed! ${newAchievements.length} new achievements unlocked:');
    for (final achievement in newAchievements) {
      print('   ${achievement.icon} ${achievement.title}');
    }
  }
}
