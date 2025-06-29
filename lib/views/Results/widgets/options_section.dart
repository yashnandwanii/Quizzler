import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallpaper_app/views/Results/widgets/question_review_card.dart';

class optionsSection extends StatelessWidget {
  const optionsSection({
    super.key,
    required this.widget,
  });

  final QuestionReviewCard widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: Colors.grey.shade600, size: 16),
            SizedBox(width: 6.w),
            Text(
              'Options',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ...widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isUserAnswer = option == widget.userAnswer;
          final isCorrectAnswer = option == widget.correctAnswer;

          Color backgroundColor = Colors.grey.shade100;
          Color borderColor = Colors.grey.shade300;

          if (isUserAnswer && isCorrectAnswer) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green;
          } else if (isUserAnswer && !isCorrectAnswer) {
            backgroundColor = Colors.red.shade50;
            borderColor = Colors.red;
          } else if (isCorrectAnswer) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green;
          }

          return Container(
            margin: EdgeInsets.only(bottom: 4.h),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Text(
                  '${String.fromCharCode(65 + index)}. ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
                Expanded(child: Text(option)),
                if (isUserAnswer)
                  Icon(
                    Icons.person,
                    color: borderColor,
                    size: 16,
                  ),
                if (isCorrectAnswer)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
