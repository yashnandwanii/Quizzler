// Fully integrated ProfilePage with in-dialog avatar selection
// for your wallpaper_app with GetX and Firestore architecture.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/common/constant.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';
import 'package:wallpaper_app/views/screens/settings_screen.dart';
import 'package:wallpaper_app/services/leaderboard_service.dart';
import 'package:wallpaper_app/services/achievements_service.dart';
import 'package:wallpaper_app/views/achievements/achievements_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _checkRetroactiveAchievements();
  }

  Future<void> _checkRetroactiveAchievements() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;

    try {
      // Check if user has any achievements unlocked
      final currentAchievements =
          await AchievementsService.getUserAchievements(userId);
      final hasUnlockedAchievements =
          currentAchievements.any((a) => a.isUnlocked);

      // If no achievements are unlocked but user has coins/quizzes, trigger retroactive check
      if (!hasUnlockedAchievements) {
        final newAchievements =
            await AchievementsService.checkAndUnlockRetroactiveAchievements(
                userId);

        // Show notifications for retroactively unlocked achievements
        if (newAchievements.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            Get.snackbar(
              'Achievements Unlocked! 🎉',
              '${newAchievements.length} achievements unlocked based on your progress!',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.purple.withValues(alpha: 0.9),
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
              margin: EdgeInsets.all(16.w),
              borderRadius: 12.r,
            );
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking retroactive achievements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final userRepo = Get.find<UserRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    UserModel? user0;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("You're not logged in.")),
      );
    }

    return Scaffold(
      backgroundColor: offwhite,
      body: FutureBuilder<UserModel?>(
        future: userRepo.getUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load user data.'));
          }

          final user = user0 ?? snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 40.h),
            child: Column(
              children: [
                _buildProfileHeader(user),
                SizedBox(height: 20.h),
                _buildStats(user),
                SizedBox(height: 20.h),
                _buildAchievements(user),
                SizedBox(height: 10.h),
                _buildMenuList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 75.r,
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : const NetworkImage(
                      'https://cdn.pixabay.com/photo/2014/06/27/16/47/person-378368_1280.png'),
              backgroundColor: Colors.grey.shade200,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  _showAvatarSelectionDialog(user);
                },
                child: Container(
                  height: 30.h,
                  width: 30.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.w),
                    borderRadius: BorderRadius.circular(100.r),
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(user.fullName,
            style: GoogleFonts.robotoMono(
                fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(user.email,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  void _showAvatarSelectionDialog(UserModel user) {
    final List<String> profiles = [
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261852/women_x41ne5.png',
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men5_fapkz3.png',
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men2_yrq6hr.png',
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men3_ouvzfm.png',
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men4_wcjrla.png',
      'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men1_xfgeld.png',
    ];

    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          backgroundColor: offwhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('Select Avatar',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
              ),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();

                    final updatedUser = user.copyWith(
                      photoUrl: profiles[index],
                    );

                    bool success = await Get.find<UserRepository>()
                        .updateUser(updatedUser);

                    if (success && user.id != null) {
                      // Sync the updated profile data to leaderboard
                      await LeaderboardService.syncUserProfileToLeaderboard(
                          user.id!);

                      Get.snackbar("Success", "Profile updated",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.withValues(alpha: 0.1),
                          colorText: Colors.green);
                    }

                    setState(() {});
                  },
                  child: CircleAvatar(
                    radius: 35.r,
                    backgroundImage: NetworkImage(profiles[index]),
                    backgroundColor: Colors.grey.shade200,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Coins', user.coins.toString(), 'assets/icons/coin.png'),
        FutureBuilder<int>(
          future: LeaderboardService.getUserRank(user.id ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildStatItem(
                  'Rank', '...', 'assets/icons/podium (1).png');
            }
            final rank = snapshot.data ?? user.rank;
            return _buildStatItem(
                'Rank', '#$rank', 'assets/icons/podium (1).png');
          },
        ),
      ],
    );
  }

  Widget _buildAchievements(UserModel user) {
    if (user.id == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, int>>(
      future: AchievementsService.getAchievementStats(user.id!),
      builder: (context, snapshot) {
        final stats =
            snapshot.data ?? {'total': 0, 'unlocked': 0, 'coinsEarned': 0};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Achievements',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16.sp)),
                GestureDetector(
                  onTap: () => Get.to(() => const AchievementsScreen()),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () => Get.to(() => const AchievementsScreen()),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.deepPurple.shade600
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAchievementStat('🏆', 'Unlocked',
                            '${stats['unlocked']}/${stats['total']}'),
                        _buildAchievementStat(
                            '🪙', 'Coins Earned', '${stats['coinsEarned']}'),
                        _buildAchievementStat('📊', 'Progress',
                            '${((stats['unlocked']! / (stats['total']! > 0 ? stats['total']! : 1)) * 100).toInt()}%'),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Tap to explore achievements',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 16.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _buildQuickAchievements(user),
          ],
        );
      },
    );
  }

  Widget _buildAchievementStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAchievements(UserModel user) {
    if (user.id == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Achievement>>(
      future: AchievementsService.getUserAchievements(user.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final achievements = snapshot.data!;
        final recentUnlocked =
            achievements.where((a) => a.isUnlocked).take(3).toList();
        final nearCompletion = achievements
            .where((a) => !a.isUnlocked && a.progressPercentage > 0.5)
            .take(2)
            .toList();

        if (recentUnlocked.isEmpty && nearCompletion.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 40.sp, color: Colors.grey.shade400),
                SizedBox(height: 8.h),
                Text(
                  'Start your achievement journey!',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Complete quizzes to unlock rewards',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recentUnlocked.isNotEmpty) ...[
              Text(
                'Recent Achievements',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentUnlocked
                      .map((achievement) =>
                          _buildQuickAchievementCard(achievement, true))
                      .toList(),
                ),
              ),
            ],
            if (nearCompletion.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Text(
                'Almost There!',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: nearCompletion
                      .map((achievement) =>
                          _buildQuickAchievementCard(achievement, false))
                      .toList(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildQuickAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      width: 120.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isUnlocked
              ? achievement.color.withValues(alpha: 0.5)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? achievement.color.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(fontSize: 24.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          if (!isUnlocked) ...[
            LinearProgressIndicator(
              value: achievement.progressPercentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              minHeight: 3.h,
            ),
            SizedBox(height: 2.h),
            Text(
              '${(achievement.progressPercentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ] else ...[
            Icon(
              Icons.check_circle,
              color: achievement.color,
              size: 16.sp,
            ),
            Text(
              '+${achievement.coinReward} coins',
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String icon) {
    return Column(
      children: [
        Image.asset(icon, height: 30.h, width: 30.w, fit: BoxFit.contain),
        SizedBox(height: 4.h),
        Text('${label.toUpperCase()} : $value',
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuTile('Settings', Icons.settings,
            () => Get.to(() => const SettingsScreen())),
        _buildMenuTile('Share', Icons.share, () {}),
        _buildMenuTile('Logout', Icons.logout, _showLogoutDialog,
            isLogout: true),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: offwhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthenticationRepository>().logout();
            },
            child: const Text('Sign Out',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, IconData icon, VoidCallback onTap,
      {bool isLogout = false}) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isLogout ? Colors.red : Colors.black87)),
        trailing:
            isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
