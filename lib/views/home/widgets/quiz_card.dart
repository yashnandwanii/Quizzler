import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/Quiz/quiz_screenn.dart';

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
      height: 180.h,
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(25.r),
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
                child: Text(category ?? 'General Knowledge',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(duration ?? '2min',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Spacer(),
              const Icon(Icons.close, color: Colors.white),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            title!,
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text('${quizzes!} Quizzes', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 8.w),
              Text(
                'Shared By\n${sharedBy ?? 'Anonymous'}',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Get.to(
                    () => QuizScreenn(
                      category: 'Linux', // e.g., 'Linux'
                      difficulty: 'Easy', // e.g., 'Easy'
                    ),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 400),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 30, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                ),
                child: Text(
                  'Start Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
