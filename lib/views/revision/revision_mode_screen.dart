import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RevisionModeScreen extends StatefulWidget {
  final List<Map<String, dynamic>> wrongAttempts;

  const RevisionModeScreen({
    super.key,
    required this.wrongAttempts,
  });

  @override
  State<RevisionModeScreen> createState() => _RevisionModeScreenState();
}

class _RevisionModeScreenState extends State<RevisionModeScreen> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    if (widget.wrongAttempts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Smart Revision',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No questions available for revision.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          'Smart Revision',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${currentIndex + 1}/${widget.wrongAttempts.length}',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (currentIndex + 1) / widget.wrongAttempts.length,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Content
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: widget.wrongAttempts.length,
              itemBuilder: (context, index) {
                return _buildRevisionCard(widget.wrongAttempts[index]);
              },
            ),
          ),
          // Navigation
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.grey.shade700,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back_ios, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Previous',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (currentIndex > 0 &&
                    currentIndex < widget.wrongAttempts.length - 1)
                  SizedBox(width: 12.w),
                if (currentIndex < widget.wrongAttempts.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_ios, size: 16.sp),
                        ],
                      ),
                    ),
                  ),
                if (currentIndex == widget.wrongAttempts.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Revision Complete! 🎉',
                          'Great job reviewing your mistakes. Keep learning!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.green.withOpacity(0.9),
                          colorText: Colors.white,
                          margin: EdgeInsets.all(16.w),
                          borderRadius: 12.r,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'Complete',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevisionCard(Map<String, dynamic> question) {
    final questionText = question['questionText'] ?? 'No question text';
    final description = question['description'] ?? '';
    final tip = question['tip'] ?? '';
    final explanation = question['explanation'] ?? '';
    final correctAnswer = question['correctAnswer'] ?? '';
    final categoryName = question['categoryName'] ?? 'Unknown';
    final options = List<String>.from(question['options'] ?? []);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              categoryName,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Question Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                    Icon(
                      Icons.quiz_outlined,
                      color: const Color(0xFF6C63FF),
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Question',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  questionText,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.blue.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (options.isNotEmpty) ...[
            SizedBox(height: 20.h),
            // Options Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Icon(
                        Icons.list_alt_outlined,
                        color: Colors.orange.shade600,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Answer Options',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isCorrect = option == correctAnswer;

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              isCorrect ? Colors.green : Colors.grey.shade300,
                          width: isCorrect ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${String.fromCharCode(65 + index)}. ',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isCorrect
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: isCorrect
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isCorrect)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18.sp,
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          if (explanation.isNotEmpty) ...[
            SizedBox(height: 20.h),
            // Explanation Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.amber.shade600,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Explanation',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    explanation,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (tip.isNotEmpty) ...[
            SizedBox(height: 20.h),
            // Tip Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: Colors.purple.shade600,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Pro Tip',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
