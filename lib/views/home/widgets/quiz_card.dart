import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/views/Quiz/enhanced_quiz_screen.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.context,
    required this.title,
    required this.category,
    required this.duration,
    required this.quizzes,
    required this.sharedBy,
    required this.avatarUrl,
    required this.backgroundColor,
  });

  final BuildContext context;
  final String? title;

  final String? category;
  final String? duration;
  final int? quizzes;
  final String? sharedBy;
  final String? avatarUrl;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210.h,
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  category!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  duration!,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Featured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Quiz title
          Text(
            title!,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 12.h),

          // Quiz details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                icon: Icons.quiz,
                text: '${quizzes!} Questions',
                color: Colors.white70,
              ),
              SizedBox(width: 16.w),
              _buildDetailItem(
                icon: Icons.timer,
                text: '${duration!} Time',
                color: Colors.white70,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Difficulty and rewards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                icon: Icons.trending_up,
                text: 'Medium Level',
                color: Colors.orange,
              ),
              SizedBox(width: 16.w),
              _buildDetailItem(
                icon: Icons.monetization_on,
                text: '+10 Coins per correct',
                color: Colors.green,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Penalty info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDetailItem(
                icon: Icons.warning,
                text: '-5 Coins per wrong',
                color: Colors.red.shade300,
              ),
              SizedBox(width: 16.w),
              _buildDetailItem(
                icon: Icons.speed,
                text: 'Bonus for speed',
                color: Colors.blue.shade300,
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Start button
          SizedBox(
            width: double.infinity,
            height: 30.h,
            child: ElevatedButton(
              onPressed: () => _startQuizForCategory(),
              style: ElevatedButton.styleFrom(
                elevation: 5,
                backgroundColor: const Color.fromARGB(255, 41, 30, 255),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _startQuizForCategory() {
    // Map card category to QuizAPI category if needed
    String apiCategory = '';
    switch (category!.toLowerCase()) {
      case 'general knowledge':
        apiCategory = '';
        break;
      case 'mathematics':
        apiCategory = 'Math';
        break;
      case 'computer science':
        apiCategory = 'Code';
        break;
      case 'devops':
        apiCategory = 'DevOps';
        break;
      default:
        apiCategory = category!;
    }
    final quizCategory = QuizCategory(
      id: category!.toLowerCase().replaceAll(' ', '_'),
      name: category!,
      iconPath: 'assets/computer-science.png',
      color: backgroundColor?.value ?? 0xFF2196F3,
      difficulty: 'Medium',
      quizCount: quizzes!,
      isActive: true,
      availableTags: [],
      apiCategory: apiCategory,
    );
    final preferences = QuizPreferences(
      difficulty: 'Medium',
      limit: quizzes!,
      singleAnswerOnly: false,
    );
    Get.to(
      () => EnhancedQuizScreen(
        category: quizCategory,
        preferences: preferences,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
}
