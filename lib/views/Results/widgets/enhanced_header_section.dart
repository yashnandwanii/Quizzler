import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';

class EnhancedHeaderSection extends StatelessWidget {
  const EnhancedHeaderSection({
    super.key,
    required this.feedback,
    required this.category,
  });

  final String feedback;
  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Category icon
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: category.iconPath.isNotEmpty
                ? Image.asset(
                    category.iconPath,
                    width: 50.w,
                    height: 50.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.emoji_events,
                        size: 50.sp,
                        color: Colors.white,
                      );
                    },
                  )
                : Icon(
                    Icons.emoji_events,
                    size: 50.sp,
                    color: Colors.white,
                  ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Quiz Completed!',
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            feedback,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
