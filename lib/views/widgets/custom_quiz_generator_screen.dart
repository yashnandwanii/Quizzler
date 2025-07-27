import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/common/constant.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';
import 'package:quizzler/services/gemini_ai_service.dart';
import 'package:quizzler/views/Quiz/enhanced_quiz_screen.dart';

class CustomQuizGeneratorScreen extends StatefulWidget {
  const CustomQuizGeneratorScreen({super.key});

  @override
  State<CustomQuizGeneratorScreen> createState() =>
      _CustomQuizGeneratorScreenState();
}

class _CustomQuizGeneratorScreenState extends State<CustomQuizGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final GeminiAIService _geminiService = Get.find<GeminiAIService>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedDifficulty = 'Easy';
  int questionCount = 10;
  String selectedLanguage = 'English';
  bool _isGenerating = false;

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<int> questionCounts = [5, 10, 15, 20];
  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _topicController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _generateQuiz() async {
    if (_topicController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a topic for your quiz',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final quizQuestions = await _geminiService.generateCustomQuiz(
        topic: _topicController.text.trim(),
        difficulty: selectedDifficulty,
        numberOfQuestions: questionCount,
        specificRequirements: _requirementsController.text.trim().isNotEmpty
            ? _requirementsController.text.trim()
            : null,
        language: selectedLanguage,
      );

      if (quizQuestions.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to generate quiz questions. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }

      // Create quiz preferences object
      final quizPreferences = QuizPreferences(
        difficulty: selectedDifficulty,
        limit: questionCount,
        tags: [_topicController.text.trim()],
        singleAnswerOnly: true,
      );

      // Create a QuizCategory for the custom topic
      final customCategory = QuizCategory(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _topicController.text.trim(),
        iconPath: 'assets/ideas.png',
        color: 0xFF6C63FF,
        difficulty: selectedDifficulty,
        quizCount: questionCount,
        isActive: true,
        availableTags: [_topicController.text.trim()],
        apiCategory: 'Custom',
      );

      // Navigate to quiz screen with generated questions
      Get.to(
        () => EnhancedQuizScreen(
          category: customCategory,
          preferences: quizPreferences,
          preGeneratedQuestions: quizQuestions,
        ),
        transition: Transition.rightToLeftWithFade,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while generating the quiz: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      appBar: AppBar(
        backgroundColor: offwhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: darkTextColor,
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Custom Quiz Generator',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF8B5CF6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'AI-Powered Quiz',
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Create personalized quizzes on any topic using advanced AI',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Topic Input
                _buildSectionTitle('Quiz Topic'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _topicController,
                  hintText:
                      'e.g., JavaScript Programming, World History, Biology...',
                  icon: Icons.topic,
                ),

                SizedBox(height: 20.h),

                // Difficulty Selection
                _buildSectionTitle('Difficulty Level'),
                SizedBox(height: 8.h),
                _buildDifficultySelector(),

                SizedBox(height: 20.h),

                // Question Count
                _buildSectionTitle('Number of Questions'),
                SizedBox(height: 8.h),
                _buildQuestionCountSelector(),

                SizedBox(height: 20.h),

                // Language Selection
                _buildSectionTitle('Language'),
                SizedBox(height: 8.h),
                _buildLanguageSelector(),

                SizedBox(height: 20.h),

                // Additional Requirements
                _buildSectionTitle('Additional Requirements (Optional)'),
                SizedBox(height: 8.h),
                _buildTextField(
                  controller: _requirementsController,
                  hintText:
                      'e.g., Focus on recent developments, include practical examples...',
                  icon: Icons.note_add,
                  maxLines: 3,
                ),

                SizedBox(height: 32.h),

                // Generate Button
                _buildGenerateButton(),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: darkTextColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.inter(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: Colors.grey.shade500,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6C63FF),
            size: 20.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: difficulties.map((difficulty) {
        final isSelected = selectedDifficulty == difficulty;
        Color difficultyColor;

        switch (difficulty) {
          case 'Easy':
            difficultyColor = const Color(0xFF4CAF50);
            break;
          case 'Medium':
            difficultyColor = const Color(0xFFFF9800);
            break;
          case 'Hard':
            difficultyColor = const Color(0xFFF44336);
            break;
          default:
            difficultyColor = const Color(0xFF6C63FF);
        }

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedDifficulty = difficulty;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: difficulty != difficulties.last ? 8.w : 0,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? difficultyColor : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? difficultyColor : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: difficultyColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                difficulty,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : darkTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionCountSelector() {
    return Row(
      children: questionCounts.map((count) {
        final isSelected = questionCount == count;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                questionCount = count;
              });
            },
            child: Container(
              margin: EdgeInsets.only(
                right: count != questionCounts.last ? 8.w : 0,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                count.toString(),
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : darkTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedLanguage,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.language,
            color: const Color(0xFF6C63FF),
            size: 20.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        dropdownColor: Colors.white,
        items: languages.map((language) {
          return DropdownMenuItem(
            value: language,
            child: Text(
              language,
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedLanguage = value!;
          });
        },
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateQuiz,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Generating Quiz...',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Generate Quiz',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
