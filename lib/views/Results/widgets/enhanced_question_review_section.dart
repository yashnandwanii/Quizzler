import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';
import 'package:wallpaper_app/views/Results/widgets/enhanced_question_card.dart';

class EnhancedQuestionReviewSection extends StatelessWidget {
  const EnhancedQuestionReviewSection({
    super.key,
    required this.userAnswers,
    required this.category,
  });

  final List<Map<String, dynamic>> userAnswers;
  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question Review',
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Tap on each question to see detailed explanations',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userAnswers.length,
            itemBuilder: (context, index) {
              return EnhancedQuestionCard(
                answer: userAnswers[index],
                questionNumber: index + 1,
                category: category,
              );
            },
          ),
        ],
      ),
    );
  }
}
