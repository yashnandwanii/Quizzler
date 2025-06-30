import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/services/quiz_history_service.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';

class QuizStatsScreen extends StatefulWidget {
  const QuizStatsScreen({super.key});

  @override
  State<QuizStatsScreen> createState() => _QuizStatsScreenState();
}

class _QuizStatsScreenState extends State<QuizStatsScreen> {
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;

      if (userId == null) return;

      final stats = await QuizHistoryService.getUserQuizStats(userId);
      setState(() {
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quiz Statistics',
          style: GoogleFonts.robotoMono(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildStatsContent(),
    );
  }

  Widget _buildStatsContent() {
    if (_userStats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'No statistics available',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Play some quizzes to see your stats!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewCard(),
          SizedBox(height: 16.h),
          _buildPerformanceCard(),
          SizedBox(height: 16.h),
          _buildAchievementsCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade600,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Total Quizzes',
                  '${_userStats['totalQuizzes'] ?? 0}',
                  Icons.quiz,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildOverviewItem(
                  'Total Score',
                  '${_userStats['totalScore'] ?? 0}',
                  Icons.star,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Categories',
                  '${_userStats['categoriesPlayed'] ?? 0}',
                  Icons.category,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildOverviewItem(
                  'Time Spent',
                  '${(_userStats['totalTimeSpent'] ?? 0) ~/ 60}m',
                  Icons.timer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
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
            'Performance',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          _buildPerformanceItem(
            'Average Score',
            '${_userStats['averageScore'] ?? 0}',
            (_userStats['averageScore'] ?? 0) / 100,
            Colors.blue,
          ),
          SizedBox(height: 16.h),
          _buildPerformanceItem(
            'Average Accuracy',
            '${_userStats['averageAccuracy'] ?? 0}%',
            (_userStats['averageAccuracy'] ?? 0) / 100,
            Colors.green,
          ),
          SizedBox(height: 16.h),
          _buildPerformanceItem(
            'Best Score',
            '${_userStats['bestScore'] ?? 0}',
            (_userStats['bestScore'] ?? 0) / 1000,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
      String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildAchievementsCard() {
    final streakCount = _userStats['streakCount'] ?? 0;
    final totalQuizzes = _userStats['totalQuizzes'] ?? 0;

    List<Map<String, dynamic>> achievements = [
      {
        'title': 'Quiz Beginner',
        'description': 'Complete your first quiz',
        'achieved': totalQuizzes >= 1,
        'icon': Icons.play_arrow,
        'color': Colors.green,
      },
      {
        'title': 'Quiz Enthusiast',
        'description': 'Complete 10 quizzes',
        'achieved': totalQuizzes >= 10,
        'icon': Icons.favorite,
        'color': Colors.red,
      },
      {
        'title': 'Quiz Master',
        'description': 'Complete 50 quizzes',
        'achieved': totalQuizzes >= 50,
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
      {
        'title': 'Streak Starter',
        'description': 'Get a 5-quiz streak',
        'achieved': streakCount >= 5,
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'Streak Master',
        'description': 'Get a 20-quiz streak',
        'achieved': streakCount >= 20,
        'icon': Icons.whatshot,
        'color': Colors.deepOrange,
      },
    ];

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
            'Achievements',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h),
          ...achievements
              .map((achievement) => _buildAchievementItem(achievement)),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    final bool achieved = achievement['achieved'];
    final Color color = achievement['color'];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: achieved ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: achieved ? color : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: achieved ? color : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement['icon'],
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: achieved ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        achieved ? Colors.grey.shade700 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (achieved)
            Icon(
              Icons.check_circle,
              color: color,
              size: 20.sp,
            ),
        ],
      ),
    );
  }
}
