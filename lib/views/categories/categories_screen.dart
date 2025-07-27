import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quizzler/common/constant.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';

import 'package:quizzler/views/Quiz/enhanced_quiz_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'linux',
      'name': 'Linux',
      'image':
          'https://cdn.pixabay.com/photo/2016/07/20/21/03/tux-1531289_1280.png',
      'color': 0xFFF39C12,
      'apiCategory': 'Linux',
    },
    {
      'id': 'devops',
      'name': 'DevOps',
      'image':
          'https://cdn.pixabay.com/photo/2018/02/12/13/58/devops-3148393_1280.png',
      'color': 0xFFE74C3C,
      'apiCategory': 'DevOps',
    },
    {
      'id': 'networking',
      'name': 'Networking',
      'image':
          'https://cdn.pixabay.com/photo/2022/09/20/01/36/computer-7466757_1280.png',
      'color': 0xFF3498DB,
      'apiCategory': 'Networking',
    },
    {
      'id': 'programming',
      'name': 'Programming',
      'image':
          'https://cdn.pixabay.com/photo/2022/04/21/08/20/code-7146975_1280.png',
      'color': 0xFF9B59B6,
      'apiCategory': 'Code',
    },
    {
      'id': 'cloud',
      'name': 'Cloud',
      'image':
          'https://cdn.pixabay.com/photo/2021/11/25/05/20/cloud-storage-6822673_1280.png',
      'color': 0xFF1ABC9C,
      'apiCategory': 'Cloud',
    },
    {
      'id': 'docker',
      'name': 'Docker',
      'image':
          'https://media.istockphoto.com/id/1401479869/vector/software-development-and-digital-technology-concept-open-source.jpg?s=612x612&w=0&k=20&c=Fx6HM9APizyjdz8DP4r9T3NjkIwIVRwiItOSAhrAePE=',
      'color': 0xFF2980B9,
      'apiCategory': 'Docker',
    },
    {
      'id': 'kubernetes',
      'name': 'Kubernetes',
      'image':
          'https://media.istockphoto.com/id/1519178892/vector/ai-servers-concept-3d-illustration.jpg?s=612x612&w=0&k=20&c=6Zsa3lbh3vBcqAT1lHsDLyZrMc1StG-GQ9RKzyBitf4=',
      'color': 0xFF8E44AD,
      'apiCategory': 'Kubernetes',
    },
  ];

  void _showQuizPreferencesDialog(Map<String, dynamic> category) {
    String selectedDifficulty = 'Easy';
    int questionCount = 10;
    bool allowMultipleCorrect = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: offwhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              title: Column(
                children: [
                  Container(
                    width: 65.w,
                    height: 65.h,
                    decoration: BoxDecoration(
                      color: Color(category['color']).withValues(alpha: 0.1),
                      border: Border.all(
                        color: Color(category['color']).withValues(alpha: 0.1),
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Image.network(
                      category['image'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    category['name'],
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(category['color']),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Difficulty Selection
                  Text(
                    'Select Difficulty Level:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ['Easy', 'Medium', 'Hard'].map((difficulty) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDifficulty = difficulty;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: selectedDifficulty == difficulty
                                ? Color(category['color'])
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            difficulty,
                            style: TextStyle(
                              color: selectedDifficulty == difficulty
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 6.h),

                  // Question Count Selection
                  Text(
                    'Number of Questions:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [5, 10, 15, 20].map((count) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            questionCount = count;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: questionCount == count
                                ? Color(category['color'])
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            count.toString(),
                            style: TextStyle(
                              color: questionCount == count
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 4.h),

                  // Multiple Correct Questions Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Allow Multiple Correct Answers:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: allowMultipleCorrect,
                        onChanged: (value) {
                          setState(() {
                            allowMultipleCorrect = value;
                          });
                        },
                        activeColor: Color(category['color']),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startQuiz(category, selectedDifficulty, questionCount,
                        allowMultipleCorrect);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(category['color']),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Start Quiz',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startQuiz(Map<String, dynamic> category, String difficulty,
      int questionCount, bool allowMultipleCorrect) {
    final preferences = QuizPreferences(
      difficulty: difficulty,
      limit: questionCount,
      singleAnswerOnly: !allowMultipleCorrect,
    );

    final quizCategory = QuizCategory(
      id: category['id'],
      name: category['name'],

      iconPath: 'assets/computer-science.png', // Default icon path
      color: category['color'],
      difficulty: difficulty,
      quizCount: 0,
      isActive: true,
      availableTags: [],
      apiCategory: category['apiCategory'],
    );

    Get.to(
      () => EnhancedQuizScreen(
        category: quizCategory,
        preferences: preferences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildCategoriesGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade900,
            Colors.purple.shade900,
            Colors.blue.shade900,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset('assets/icons/quiz.png',
              height: 30.h, width: 30.w, fit: BoxFit.contain),
          SizedBox(width: 10.w),
          Text(
            'Categories',
            style: GoogleFonts.robotoMono(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(_categories[index]);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final color = Color(category['color']);

    return GestureDetector(
      onTap: () => _showQuizPreferencesDialog(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                      width: double.infinity,
                      height: 65.h,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Image.network(category['image'],
                          fit: BoxFit.cover, width: 50.w, height: 50.h,
                          errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      })),
                  SizedBox(height: 6.h),
                  // Title
                  Text(
                    category['name'],
                    style: GoogleFonts.robotoMono(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => _showQuizPreferencesDialog(category),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow, size: 18.sp),
                    SizedBox(width: 4.w),
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
      ),
    );
  }
}
