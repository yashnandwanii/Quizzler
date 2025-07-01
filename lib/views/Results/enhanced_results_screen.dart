import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';
import 'package:wallpaper_app/services/leaderboard_service.dart';
import 'package:wallpaper_app/services/achievements_service.dart';
import 'package:wallpaper_app/services/daily_challenge_service.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/views/Results/widgets/enhanced_header_section.dart';
import 'package:wallpaper_app/views/Results/widgets/enhanced_question_review_section.dart';
import 'package:wallpaper_app/views/home/main_tab_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/services/firestore_service.dart';

class EnhancedResultsScreen extends StatefulWidget {
  final QuizCategory category;
  final QuizPreferences preferences;
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final int bonusPoints;
  final int totalScore;
  final int coinsEarned;
  final int timeSpent;
  final List<Map<String, dynamic>> userAnswers;
  final String quizId;

  const EnhancedResultsScreen({
    super.key,
    required this.category,
    required this.preferences,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.bonusPoints,
    required this.totalScore,
    required this.coinsEarned,
    required this.timeSpent,
    required this.userAnswers,
    required this.quizId,
  });

  @override
  _EnhancedResultsScreenState createState() => _EnhancedResultsScreenState();
}

class _EnhancedResultsScreenState extends State<EnhancedResultsScreen> {
  late ConfettiController _confettiController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _saveQuizResultAndUpdateStats();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scorePercentage =
        (widget.correctAnswers / widget.totalQuestions) * 100;

    String feedback = _getFeedback(scorePercentage);

    return Scaffold(
      backgroundColor: Color(widget.category.color),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(widget.category.color),
              Color(widget.category.color).withValues(alpha: 0.8),
              Color(widget.category.color).withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          // Header Section
                          EnhancedHeaderSection(
                            feedback: feedback,
                            category: widget.category,
                          ),

                          SizedBox(height: 20.h),

                          // Score Summary Cards
                          _buildScoreSummary(),

                          SizedBox(height: 20.h),

                          // Quiz Info Card
                          _buildQuizInfoCard(),

                          SizedBox(height: 20.h),

                          // Question Review Section
                          EnhancedQuestionReviewSection(
                            userAnswers: widget.userAnswers,
                            category: widget.category,
                          ),

                          SizedBox(height: 20.h),

                          // Action Buttons
                          _buildActionButtons(),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coins earned
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.orange.shade600],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.white, size: 24),
                SizedBox(width: 8.w),
                Text(
                  'You earned ${widget.coinsEarned} coins!',
                  style: GoogleFonts.robotoMono(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Score grid
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Correct',
                  widget.correctAnswers.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildScoreCard(
                  'Incorrect',
                  widget.incorrectAnswers.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Accuracy',
                  '${((widget.correctAnswers / widget.totalQuestions) * 100).toStringAsFixed(1)}%',
                  Colors.blue,
                  Icons.tag,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildScoreCard(
                  'Bonus',
                  '${widget.bonusPoints}',
                  Colors.amber,
                  Icons.star,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildScoreCard(
            'Total Score',
            '${widget.totalScore}',
            Color(widget.category.color),
            Icons.emoji_events,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfoCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Details',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Category', widget.category.name, Icons.category),
          _buildInfoRow(
              'Difficulty', widget.preferences.difficulty, Icons.trending_up),
          _buildInfoRow('Questions', '${widget.totalQuestions}', Icons.quiz),
          _buildInfoRow('Time Spent',
              '${(widget.timeSpent / 60).toStringAsFixed(1)} min', Icons.timer),
          if (widget.preferences.tags.isNotEmpty)
            _buildInfoRow(
                'Topics', widget.preferences.tags.join(', '), Icons.label),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Color(widget.category.color)),
          SizedBox(width: 8.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color color, IconData icon,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: fullWidth ? 24.sp : 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(
                    () => const MainTabView(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(widget.category.color),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to category with same preferences
                  Get.offAll(
                    () => MainTabView(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getFeedback(double scorePercentage) {
    if (scorePercentage == 100) {
      return "🎉 Perfect Score! You're a ${widget.category.name} Master!";
    } else if (scorePercentage >= 80) {
      return "👏 Excellent! You know your ${widget.category.name}!";
    } else if (scorePercentage >= 60) {
      return "💪 Good job! Keep practicing ${widget.category.name}!";
    } else {
      return "🔥 Don't give up! ${widget.category.name} takes practice!";
    }
  }

  Future<void> _saveQuizResultAndUpdateStats() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;
      if (userId == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      final userName = userDoc.data()?['fullName'] ?? 'Unknown';

      // Save quiz history
      await FirestoreService.addQuizHistory(
        userId,
        widget.quizId,
        {
          'quizId': widget.quizId,
          'categoryId': widget.category.id,
          'categoryName': widget.category.name,
          'score': widget.totalScore,
          'totalQuestions': widget.totalQuestions,
          'correctAnswers': widget.correctAnswers,
          'incorrectAnswers': widget.incorrectAnswers,
          'timeSpent': widget.timeSpent,
          'bonusPoints': widget.bonusPoints,
          'userAnswers': widget.userAnswers,
          'accuracy':
              (widget.correctAnswers / widget.totalQuestions * 100).round(),
        },
      );

      // Update leaderboard
      await LeaderboardService.updateUserStats(
        userId,
        widget.totalScore,
        widget.coinsEarned,
        name: userName,
      );

      // Update user profile
      await FirestoreService.updateUserProfileFields(userId, {
        'coins': FieldValue.increment(widget.coinsEarned),
        'totalScore': FieldValue.increment(widget.totalScore),
        'quizzesPlayed': FieldValue.increment(1),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      });

      // Check and update achievements
      final isPerfectScore = widget.correctAnswers == widget.totalQuestions;
      final accuracy =
          (widget.correctAnswers / widget.totalQuestions * 100).round();

      // Get current rank for achievements
      final rank = await LeaderboardService.getUserRank(userId);

      // Prepare user stats for achievement calculation
      final userStats = {
        'rank': rank,
        'averageAccuracy': accuracy,
        'coinsEarned': widget.coinsEarned, // Coins earned from this quiz
      };

      final quizData = {
        'timeSpent': widget.timeSpent,
        'isPerfectScore': isPerfectScore,
        'categoryName': widget.category.name,
        'accuracy': accuracy,
      };

      // Update achievements and get newly unlocked ones
      final newAchievements =
          await AchievementsService.updateAchievementProgress(
        userId,
        userStats,
        quizData,
      );

      // Update daily challenges
      final completedChallenges =
          await DailyChallengeService.updateChallengeProgress(
        userId,
        {
          'accuracy': accuracy,
          'categoryName': widget.category.name,
          'timeSpent': widget.timeSpent,
        },
      );

      // Show notifications for achievements and challenges
      if (newAchievements.isNotEmpty) {
        _showAchievementNotifications(newAchievements);
      }

      if (completedChallenges.isNotEmpty) {
        _showChallengeNotifications(completedChallenges);
      }
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showAchievementNotifications(List<Achievement> achievements) {
    for (final achievement in achievements) {
      Future.delayed(
          Duration(milliseconds: achievements.indexOf(achievement) * 1000), () {
        Get.snackbar(
          'Achievement Unlocked! 🏆',
          '${achievement.title}\n+${achievement.coinReward} coins earned!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: achievement.color.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
          icon: Text(achievement.icon, style: TextStyle(fontSize: 24.sp)),
          shouldIconPulse: true,
        );
      });
    }
  }

  void _showChallengeNotifications(List<DailyChallenge> challenges) {
    for (final challenge in challenges) {
      Future.delayed(
          Duration(milliseconds: (challenges.indexOf(challenge) + 3) * 1000),
          () {
        Get.snackbar(
          'Challenge Complete! 🎯',
          '${challenge.title}\n+${challenge.coinReward} coins earned!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: challenge.color.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
          icon: Text(challenge.icon, style: TextStyle(fontSize: 24.sp)),
          shouldIconPulse: true,
        );
      });
    }
  }
}
