import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wallpaper_app/views/Results/widgets/answer_section.dart';
import 'package:wallpaper_app/views/Results/widgets/info_section.dart';
import 'package:wallpaper_app/views/Results/widgets/options_section.dart';

class QuestionReviewCard extends StatefulWidget {
  final int questionNumber;
  final String question;
  final String? description;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;
  final String? tip;
  final List<String> options;
  final int bonusPoints;

  const QuestionReviewCard({
    super.key,
    required this.questionNumber,
    required this.question,
    this.description,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
    this.tip,
    required this.options,
    required this.bonusPoints,
  });

  @override
  State<QuestionReviewCard> createState() => _QuestionReviewCardState();
}

class _QuestionReviewCardState extends State<QuestionReviewCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Question header
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: widget.isCorrect
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                  bottom: Radius.circular(isExpanded ? 0 : 12.r),
                ),
                border: Border.all(
                  color: widget.isCorrect ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: widget.isCorrect ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        widget.isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${widget.questionNumber}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.question,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (widget.description != null &&
                      widget.description!.isNotEmpty) ...[
                    infoSection(
                        title: 'Description',
                        content: widget.description!,
                        icon: Icons.info_outline,
                        color: Colors.blue),
                    SizedBox(height: 12.h),
                  ],

                  // Options
                  optionsSection(widget: widget),
                  SizedBox(height: 12.h),

                  // User's answer
                  answerSection(
                      title: 'Your Answer',
                      answer: widget.userAnswer,
                      color: widget.isCorrect ? Colors.green : Colors.red,
                      icon: Icons.person),
                  SizedBox(height: 8.h),

                  // Correct answer
                  answerSection(
                      title: 'Correct Answer',
                      answer: widget.correctAnswer,
                      color: Colors.green,
                      icon: Icons.check_circle),
                  SizedBox(height: 12.h),

                  // Explanation
                  if (widget.explanation.isNotEmpty)
                    infoSection(
                        title: 'Explanation',
                        content: widget.explanation,
                        icon: Icons.lightbulb_outline,
                        color: Colors.orange),

                  // Tip
                  if (widget.tip != null && widget.tip!.isNotEmpty) ...[
                    if (widget.explanation.isNotEmpty) SizedBox(height: 12.h),
                    infoSection(
                        title: 'Tip',
                        content: widget.tip!,
                        icon: Icons.lightbulb,
                        color: Colors.amber),
                  ],

                  // Bonus points
                  SizedBox(height: 12.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 8.w),
                        Text(
                          'Bonus Points: ${widget.bonusPoints}',
                          style: TextStyle(
                            color: Colors.amber.shade800,
                            fontWeight: FontWeight.w600,
                          ),
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
}
