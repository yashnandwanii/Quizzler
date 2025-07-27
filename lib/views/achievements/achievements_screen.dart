import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:confetti/confetti.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/services/achievements_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  List<Achievement> achievements = [];
  Map<String, int> stats = {};
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;

    try {
      final userAchievements =
          await AchievementsService.getUserAchievements(userId);
      final achievementStats =
          await AchievementsService.getAchievementStats(userId);

      setState(() {
        achievements = userAchievements;
        stats = achievementStats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshAchievements() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      // First trigger retroactive achievement checking
      final newAchievements =
          await AchievementsService.checkAndUnlockRetroactiveAchievements(
              userId);

      // Show celebration if achievements were unlocked
      if (newAchievements.isNotEmpty) {
        _confettiController.play();
        Get.snackbar(
          'New Achievements! 🎉',
          '${newAchievements.length} achievements unlocked!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.purple.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: EdgeInsets.all(16.w),
          borderRadius: 12.r,
        );
      }

      // Then reload achievements normally
      await _loadAchievements();
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to refresh achievements',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
    }
  }

  List<Achievement> get filteredAchievements {
    switch (selectedFilter) {
      case 'unlocked':
        return achievements.where((a) => a.isUnlocked).toList();
      case 'locked':
        return achievements.where((a) => !a.isUnlocked).toList();
      case 'bronze':
        return achievements.where((a) => a.rarity == 'bronze').toList();
      case 'silver':
        return achievements.where((a) => a.rarity == 'silver').toList();
      case 'gold':
        return achievements.where((a) => a.rarity == 'gold').toList();
      case 'legend':
        return achievements.where((a) => a.rarity == 'legend').toList();
      default:
        return achievements;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAchievements,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    _buildStatsHeader(),
                    _buildFilterTabs(),
                    Expanded(child: _buildAchievementsList()),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                    colors: const [
                      Colors.purple,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.green
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('🏆', 'Unlocked',
              '${stats['unlocked'] ?? 0}/${stats['total'] ?? 0}'),
          _buildStatItem('🪙', 'Coins Earned', '${stats['coinsEarned'] ?? 0}'),
          _buildStatItem('📊', 'Progress',
              '${((stats['unlocked'] ?? 0) / (stats['total'] ?? 1) * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24.sp)),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.grid_view},
      {'key': 'unlocked', 'label': 'Unlocked', 'icon': Icons.lock_open},
      {'key': 'locked', 'label': 'Locked', 'icon': Icons.lock},
      {'key': 'bronze', 'label': 'Bronze', 'icon': Icons.emoji_events},
    ];

    return Container(
      height: 60.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter['key'];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = filter['key'] as String;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.white,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.deepPurple.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    filter['label'] as String,
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAchievementsList() {
    final filtered = filteredAchievements;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              'No achievements found',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete more quizzes to unlock achievements!',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(filtered[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progressPercentage;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isUnlocked
            ? Border.all(
                color: achievement.color.withValues(alpha: 0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? achievement.color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isUnlocked ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isUnlocked)
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: achievement.color,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  achievement.rarity.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? achievement.color.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color:
                          isUnlocked ? achievement.color : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      achievement.icon,
                      style: TextStyle(
                        fontSize: 24.sp,
                        color: isUnlocked ? null : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (isUnlocked)
                            Icon(
                              Icons.check_circle,
                              color: achievement.color,
                              size: 20.sp,
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        achievement.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Progress bar for locked achievements
                      if (!isUnlocked) ...[
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    achievement.color),
                                minHeight: 6.h,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${achievement.progress}/${achievement.targetValue}',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                      ],

                      // Coin reward
                      Row(
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: Colors.amber,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${achievement.coinReward} coins',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isUnlocked && achievement.unlockedAt != null) ...[
                            const Spacer(),
                            Text(
                              'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'today';
    } else if (difference == 1) {
      return 'yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
