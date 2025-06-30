import 'package:wallpaper_app/services/leaderboard_service.dart';

// Test script to verify dynamic rank calculation
void testRankCalculation() async {
  // Example usage:
  // When a user completes a quiz and their score is updated,
  // the rank should be automatically recalculated

  String testUserId = "test-user-123";

  // Update user stats (this will trigger rank recalculation)
  await LeaderboardService.updateUserStats(testUserId, 100, 50,
      name: "Test User");

  // Get the user's current rank
  int currentRank = await LeaderboardService.getUserRank(testUserId);
  print("User $testUserId has rank: $currentRank");
}
