import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/services/quiz_history_service.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/views/quiz_history/quiz_stats_screen.dart';
import 'package:wallpaper_app/views/quiz_history/quiz_replay_screen.dart';

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
            _buildHeader(),
            _buildStatsCard(),
            _buildFilterSection(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildHistoryList(),
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
            onTap: () {
              Get.to(
                () => const QuizStatsScreen(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: Column(
              children: [
                Image.asset('assets/icons/analytics.png',
                    height: 20.h, width: 20.w, fit: BoxFit.contain),
                SizedBox(height: 5.h),
                Text('Stats',
                    style: GoogleFonts.robotoMono(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          SizedBox(width: 25.w),
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
                child: _buildStatItem(
                  'Streak',
                  '${_userStats['streakCount'] ?? 0}',
                  Icons.local_fire_department,
                  Colors.red,
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
