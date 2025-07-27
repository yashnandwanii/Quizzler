import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';

class EnhancedQuestionCard extends StatefulWidget {
  final Map<String, dynamic> answer;
  final int questionNumber;
  final QuizCategory category;

  const EnhancedQuestionCard({
    super.key,
    required this.answer,
    required this.questionNumber,
    required this.category,
  });

  @override
  State<EnhancedQuestionCard> createState() => _EnhancedQuestionCardState();
}

class _EnhancedQuestionCardState extends State<EnhancedQuestionCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final userAnswer = widget.answer['userAnswer'] ?? '';
    final correctAnswer = widget.answer['correctAnswer'] ?? '';
    final isCorrect = widget.answer['isCorrect'] ?? false;
    final options = List<String>.from(widget.answer['options'] ?? []);
    final explanation = widget.answer['explanation'] ?? '';
    final bonusPoints = widget.answer['bonusPoints'] ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
                color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                  bottom: Radius.circular(isExpanded ? 0 : 16.r),
                ),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 18.sp,
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
                          widget.answer['question'] ?? '',
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
                  if (bonusPoints > 0) ...[
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12.sp),
                          SizedBox(width: 2.w),
                          Text(
                            '+$bonusPoints',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
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
                  if (widget.answer['description']?.isNotEmpty == true) ...[
                    _buildInfoSection(
                      'Description',
                      widget.answer['description'],
                      Icons.info_outline,
                      Colors.blue,
                    ),
                    SizedBox(height: 12.h),
                  ],

                  // Options
                  _buildOptionsSection(options, userAnswer, correctAnswer),
                  SizedBox(height: 12.h),

                  // Answer summary
                  _buildAnswerSummary(userAnswer, correctAnswer, isCorrect),

                  // Explanation
                  if (explanation.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildInfoSection(
                      'Explanation',
                      explanation,
                      Icons.lightbulb_outline,
                      Colors.orange,
                    ),
                  ],

                  // Tip
                  if (widget.answer['tip']?.isNotEmpty == true) ...[
                    SizedBox(height: 12.h),
                    _buildInfoSection(
                      'Tip',
                      widget.answer['tip'],
                      Icons.lightbulb,
                      Colors.amber,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(
      List<String> options, String userAnswer, String correctAnswer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: Colors.grey.shade600, size: 16.sp),
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
        SizedBox(height: 8.h),
        ...options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isUserAnswer = option == userAnswer;
          final isCorrectAnswer = option == correctAnswer;

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
                    size: 16.sp,
                  ),
                if (isCorrectAnswer)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16.sp,
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAnswerSummary(
      String userAnswer, String correctAnswer, bool isCorrect) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.blue, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'Your Answer: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: Text(
                  userAnswer,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'Correct Answer: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: Text(
                  correctAnswer,
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
      String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
