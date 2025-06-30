import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizReplayScreen extends StatefulWidget {
  final Map<String, dynamic> quizData;

  const QuizReplayScreen({super.key, required this.quizData});

  @override
  State<QuizReplayScreen> createState() => _QuizReplayScreenState();
}

class _QuizReplayScreenState extends State<QuizReplayScreen> {
  int currentQuestionIndex = 0;
  List<Map<String, dynamic>> userAnswers = [];

  @override
  void initState() {
    super.initState();
    userAnswers =
        List<Map<String, dynamic>>.from(widget.quizData['userAnswers'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    if (userAnswers.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Review'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No quiz data available for review'),
        ),
      );
    }

    final currentQuestion = userAnswers[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quiz Review',
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuestionCard(currentQuestion),
                  SizedBox(height: 16.h),
                  _buildAnswerSection(currentQuestion),
                  SizedBox(height: 16.h),
                  if (currentQuestion['explanation']?.isNotEmpty == true)
                    _buildExplanationCard(currentQuestion),
                ],
              ),
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.blue.shade600,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${currentQuestionIndex + 1} of ${userAnswers.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${widget.quizData['categoryName'] ?? 'Quiz'}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / userAnswers.length,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            question['question'] ?? '',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (question['description']?.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                question['description'],
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blue.shade800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerSection(Map<String, dynamic> question) {
    final userAnswer = question['userAnswer'] ?? '';
    final correctAnswer = question['correctAnswer'] ?? '';
    final isCorrect = question['isCorrect'] ?? false;
    final options = List<String>.from(question['options'] ?? []);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                isCorrect ? 'Correct Answer' : 'Incorrect Answer',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Options
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final isUserAnswer = option == userAnswer;
            final isCorrectOption = option == correctAnswer;

            Color backgroundColor = Colors.grey.shade100;
            Color borderColor = Colors.grey.shade300;
            Color textColor = Colors.black87;

            if (isUserAnswer && isCorrectOption) {
              backgroundColor = Colors.green.shade50;
              borderColor = Colors.green;
              textColor = Colors.green.shade800;
            } else if (isUserAnswer && !isCorrectOption) {
              backgroundColor = Colors.red.shade50;
              borderColor = Colors.red;
              textColor = Colors.red.shade800;
            } else if (isCorrectOption) {
              backgroundColor = Colors.green.shade50;
              borderColor = Colors.green;
              textColor = Colors.green.shade800;
            }

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Text(
                    '${String.fromCharCode(65 + index)}. ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                  if (isUserAnswer)
                    Icon(
                      Icons.person,
                      color: borderColor,
                      size: 16.sp,
                    ),
                  if (isCorrectOption)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16.sp,
                    ),
                ],
              ),
            );
          }),

          SizedBox(height: 16.h),

          // Summary
          Container(
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
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard(Map<String, dynamic> question) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Explanation',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            question['explanation'],
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: currentQuestionIndex > 0
                  ? () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back, size: 18.sp),
                  SizedBox(width: 4.w),
                  const Text('Previous'),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: currentQuestionIndex < userAnswers.length - 1
                  ? () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Next'),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, size: 18.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
