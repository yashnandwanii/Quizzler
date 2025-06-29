import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/common/constant.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';
import 'package:wallpaper_app/views/screens/settings_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final userRepo = Get.find<UserRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    if (userId == null) {
      // Handle non-logged-in user case
      return const Scaffold(
        body: Center(
          child: Text("You're not logged in."),
        ),
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

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 40.h),
            child: Column(
              children: [
                _buildProfileHeader(user),
                SizedBox(height: 20.h),
                _buildStats(user),
                SizedBox(height: 20.h),
                _buildAchievements(user),
                SizedBox(height: 20.h),
                _buildQuizStats(user),
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
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black.withValues(alpha: 0.1), width: 2),
                borderRadius: BorderRadius.circular(100),
                color: Colors.black,
              ),
              child: CircleAvatar(
                radius: 60.r,
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : const AssetImage('assets/app_logo.png') as ImageProvider,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                child: CircleAvatar(
                  radius: 10.r,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          user.fullName,
          style: GoogleFonts.robotoMono(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Coins', user.coins.toString(), Icons.monetization_on),
        _buildStatItem('Rank', '#${user.rank}', Icons.leaderboard),
      ],
    );
  }

  Widget _buildAchievements(UserModel user) {
    // Placeholder: You can fetch and display achievements from Firestore if implemented
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text('Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('No achievements yet.',
              style: TextStyle(color: Colors.grey.shade600)),
        ),
      ],
    );
  }

  Widget _buildQuizStats(UserModel user) {
    // Placeholder: You can fetch and display quizzes played from Firestore if implemented
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text('Quizzes Played',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text('Feature coming soon!',
              style: TextStyle(color: Colors.grey.shade600)),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue),
        SizedBox(height: 4.h),
        Text(value,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        Text(label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuTile(
          title: 'Settings',
          icon: Icons.settings,
          onTap: () => Get.to(() => const SettingsScreen()),
        ),
        _buildMenuTile(
          title: 'Share',
          icon: Icons.share,
          onTap: () {},
        ),
        _buildMenuTile(
          title: 'Logout',
          icon: Icons.logout,
          onTap: _showLogoutDialog,
          isLogout: true,
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Get.find<AuthenticationRepository>().logout();
              Get.offAll(() => const QuizSplashScreen());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isLogout ? Colors.red : Colors.black87,
          ),
        ),
        trailing: isLogout
            ? null
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
        onTap: onTap,
      ),
    );
  }
}
