import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/services/quiz_history_service.dart';
import 'package:quizzler/views/quiz_history/quiz_replay_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  List<Map<String, dynamic>> _quizHistory = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  String? _selectedCategory;
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadQuizHistory();
  }

  Future<void> _loadQuizHistory() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;
      if (userId == null) return;

      // Get quiz history with increased limit for better display
      final allHistory =
          await QuizHistoryService.getUserQuizHistory(userId, limit: 100);
      debugPrint('Loaded ${allHistory.length} quiz history records');

      final categories = allHistory
          .map((q) => q['categoryName'] as String? ?? '')
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList();

      List<Map<String, dynamic>> filteredHistory;

      if (_selectedCategory == null || _selectedCategory == 'All Categories') {
        filteredHistory = allHistory;
      } else {
        filteredHistory = allHistory
            .where((q) => q['categoryName'] == _selectedCategory)
            .toList();
      }

      // Additional sorting to ensure timestamp order (fallback)
      filteredHistory.sort((a, b) {
        final aTime = a['timestamp'] ?? a['completedAt'];
        final bTime = b['timestamp'] ?? b['completedAt'];

        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        try {
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

          return bDateTime
              .compareTo(aDateTime); // Descending order (newest first)
        } catch (e) {
          debugPrint('Error comparing timestamps: $e');
          return 0;
        }
      });

      final stats = await QuizHistoryService.getUserQuizStats(userId);
      debugPrint('Loaded stats: $stats');

      setState(() {
        _quizHistory = filteredHistory;
        _userStats = stats;
        _availableCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading quiz history: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(), // Fixed header
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildStatsCard(),
                    _buildStreakDetailsCard(),
                    _buildFilterSection(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _buildHistoryList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
            Colors.blue.shade900,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/history.png',
            height: 30.h,
            width: 30.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          Text(
            'Quiz History',
            style: GoogleFonts.robotoMono(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _loadQuizHistory,
            child: Image.asset('assets/icons/refresh.png',
                height: 25.h, width: 25.w, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_userStats.isEmpty) return const SizedBox();

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
            'Your Performance',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Quizzes',
                  '${_userStats['totalQuizzes'] ?? 0}',
                  Icons.quiz,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Average Score',
                  '${_userStats['averageScore'] ?? 0}',
                  Icons.star,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Accuracy',
                  '${_userStats['averageAccuracy'] ?? 0}%',
                  Icons.tag,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildEnhancedStreakItem(
                  'Current Streak',
                  '${_userStats['streakCount'] ?? 0}',
                  _getStreakMessage(_userStats['streakCount'] ?? 0),
                  Icons.local_fire_department,
                  _getStreakColor(_userStats['streakCount'] ?? 0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStreakItem(
      String label, String value, String message, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 4.w),
              if (int.parse(value) > 0)
                ...List.generate(
                    (int.parse(value) / 5).ceil().clamp(0, 3),
                    (index) =>
                        Icon(Icons.star, color: Colors.amber, size: 12.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return const Color(0xFF6C63FF); // Purple for legendary
    if (streak >= 20) return const Color(0xFFFF6B6B); // Red for amazing
    if (streak >= 10) return const Color(0xFF4ECDC4); // Teal for great
    if (streak >= 5) return const Color(0xFFFFE66D); // Yellow for good
    if (streak >= 1) return const Color(0xFF95E1D3); // Light green for started
    return Colors.grey; // Grey for no streak
  }

  String _getStreakMessage(int streak) {
    if (streak >= 30) return 'Legendary! 🏆';
    if (streak >= 20) return 'Amazing! 🔥';
    if (streak >= 15) return 'Incredible! ⭐';
    if (streak >= 10) return 'Great job! 💪';
    if (streak >= 7) return 'Keep going! 🚀';
    if (streak >= 5) return 'Good streak! 👍';
    if (streak >= 3) return 'Building up! 📈';
    if (streak >= 1) return 'Started! 🌱';
    return 'Start today! 💡';
  }

  Widget _buildStreakDetailsCard() {
    if (_userStats.isEmpty) return const SizedBox();

    final currentStreak = _userStats['streakCount'] ?? 0;
    final longestStreak = _userStats['longestStreak'] ?? 0;
    final streaksThisWeek = _userStats['streaksThisWeek'] ?? 0;
    final streaksThisMonth = _userStats['streaksThisMonth'] ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStreakColor(currentStreak).withValues(alpha: 0.1),
            _getStreakColor(currentStreak).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _getStreakColor(currentStreak).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: _getStreakColor(currentStreak),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Streak Analytics',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _getStreakColor(currentStreak),
                ),
              ),
              const Spacer(),
              if (currentStreak > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getStreakColor(currentStreak),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Active',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatItem(
                  'Longest',
                  '$longestStreak days',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMiniStatItem(
                  'This Week',
                  '$streaksThisWeek days',
                  Icons.calendar_view_week,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildMiniStatItem(
                  'This Month',
                  '$streaksThisMonth days',
                  Icons.calendar_month,
                  Colors.green,
                ),
              ),
            ],
          ),
          if (currentStreak == 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Start a new streak by taking a quiz today!',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    if (_availableCategories.isEmpty) return const SizedBox();
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory ?? 'All Categories',
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: 'Filter by Category',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        items: [
          DropdownMenuItem(
              value: 'All Categories', child: Text('All Categories')),
          ..._availableCategories.map(
            (cat) => DropdownMenuItem(
              value: cat,
              child: Text(cat),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() => _selectedCategory = value);
          _loadQuizHistory();
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_quizHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'No quiz history yet',
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start playing quizzes to see your history!',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    // Sort by timestamp or completedAt descending (newest first)
    final sortedHistory = List<Map<String, dynamic>>.from(_quizHistory);
    sortedHistory.sort((a, b) {
      final aTime = a['timestamp'] ?? a['completedAt'];
      final bTime = b['timestamp'] ?? b['completedAt'];

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      try {
        int aTimestamp;
        int bTimestamp;

        if (aTime is Timestamp) {
          aTimestamp = aTime.millisecondsSinceEpoch;
        } else if (aTime is DateTime) {
          aTimestamp = aTime.millisecondsSinceEpoch;
        } else {
          // Fallback: try to get millisecondsSinceEpoch if available
          aTimestamp = aTime?.millisecondsSinceEpoch ?? 0;
        }

        if (bTime is Timestamp) {
          bTimestamp = bTime.millisecondsSinceEpoch;
        } else if (bTime is DateTime) {
          bTimestamp = bTime.millisecondsSinceEpoch;
        } else {
          // Fallback: try to get millisecondsSinceEpoch if available
          bTimestamp = bTime?.millisecondsSinceEpoch ?? 0;
        }

        return bTimestamp
            .compareTo(aTimestamp); // Descending order (newest first)
      } catch (e) {
        debugPrint('Error sorting by timestamp: $e');
        return 0;
      }
    });

    return RefreshIndicator(
      onRefresh: _loadQuizHistory,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final quiz = sortedHistory[index];
          final score = quiz['score'] ?? 0;
          final totalQuestions = quiz['totalQuestions'] ?? 1;
          final accuracy = quiz['accuracy'] ?? 0;
          final categoryName = quiz['categoryName'] ?? 'Unknown';
          final completedAt = quiz['timestamp'] ?? quiz['completedAt'];
          String timeAgo = 'Unknown time';
          if (completedAt != null) {
            try {
              DateTime date;
              if (completedAt is Timestamp) {
                date = completedAt.toDate();
              } else if (completedAt is DateTime) {
                date = completedAt;
              } else {
                // Try to parse as timestamp
                date = DateTime.fromMillisecondsSinceEpoch(completedAt);
              }

              final now = DateTime.now();
              final difference = now.difference(date);

              if (difference.inDays > 7) {
                timeAgo = '${(difference.inDays / 7).floor()} weeks ago';
              } else if (difference.inDays > 0) {
                timeAgo = '${difference.inDays} days ago';
              } else if (difference.inHours > 0) {
                timeAgo = '${difference.inHours} hours ago';
              } else if (difference.inMinutes > 0) {
                timeAgo = '${difference.inMinutes} minutes ago';
              } else {
                timeAgo = 'Just now';
              }
            } catch (e) {
              debugPrint('Error parsing timestamp: $e');
              timeAgo = 'Recently';
            }
          }

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score: $score points',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Accuracy: $accuracy% ($totalQuestions questions)',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => QuizReplayScreen(quizData: quiz),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Review',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
