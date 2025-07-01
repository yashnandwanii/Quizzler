import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';
import 'package:wallpaper_app/services/enhanced_quiz_api_service.dart';
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:wallpaper_app/views/Results/enhanced_results_screen.dart';
import 'package:wallpaper_app/services/enhanced_category_service.dart';
import 'package:wallpaper_app/services/gemini_ai_service.dart';

class EnhancedQuizScreen extends StatefulWidget {
  final QuizCategory category;
  final QuizPreferences preferences;
  final List<QuizModel>? preGeneratedQuestions; // For AI-generated quizzes

  const EnhancedQuizScreen({
    super.key,
    required this.category,
    required this.preferences,
    this.preGeneratedQuestions,
  });

  @override
  State<EnhancedQuizScreen> createState() => _EnhancedQuizScreenState();
}

class _EnhancedQuizScreenState extends State<EnhancedQuizScreen> {
  late List<QuizModel> quizData;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  int currentIndex = 0;
  int seconds = 60;
  Timer? timer;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  bool isLoadingOptions = false;
  int totalBonusPoints = 0;
  int currentBonusPoints = 60;
  bool isAnswered = false;
  bool showTip = false;

  List<String> optionsList = [];
  List<Color> optionColors = List.generate(6, (index) => Colors.white);

  List<Map<String, dynamic>> userAnswers = [];

  @override
  void initState() {
    super.initState();
    initializeQuiz();
  }

  Future<void> initializeQuiz() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Use pre-generated questions if available (for AI quizzes)
      if (widget.preGeneratedQuestions != null &&
          widget.preGeneratedQuestions!.isNotEmpty) {
        quizData = widget.preGeneratedQuestions!;
        setState(() {
          isLoading = false;
        });
        startBonusTimer();
        return;
      }

      // Try to fetch quizzes using enhanced API service for regular quizzes
      try {
        if (widget.category.apiCategory.isNotEmpty) {
          quizData = await EnhancedQuizApiService.fetchQuizzesWithPreferences(
            category: widget.category.apiCategory,
            preferences: widget.preferences,
          );
        } else {
          // For general knowledge or categories without specific API mapping
          quizData =
              await EnhancedQuizApiService.fetchRandomQuizzesWithPreferences(
            preferences: widget.preferences,
          );
        }
      } catch (e) {
        // If API fails, offer fallback to AI-generated questions
        if (e is ApiServerException ||
            e is ApiKeyException ||
            e is TimeoutException) {
          await _handleAPIFailureWithFallback(e.toString());
          return;
        } else {
          rethrow; // Re-throw other errors
        }
      }

      if (quizData.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage =
              'No questions found for the selected criteria. Try adjusting your preferences.';
          isLoading = false;
        });
        return;
      }

      // Update category quiz count
      await EnhancedCategoryService.updateQuizCount(widget.category.id, 1);

      setState(() {
        isLoading = false;
      });

      startBonusTimer();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage =
            'Failed to load quiz questions. Please check your internet connection and try again.';
        isLoading = false;
      });
      debugPrint('Error initializing quiz: $e');
    }
  }

  void startBonusTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        gotoNextQuestion();
      } else {
        setState(() {
          seconds--;
          if (currentBonusPoints > 0) {
            currentBonusPoints--;
          }
        });
      }
    });
  }

  void gotoNextQuestion() {
    setState(() {
      isLoadingOptions = false;
      resetOptionColors();
      currentIndex++;
      timer!.cancel();
      seconds = 60;
      currentBonusPoints = 60;
      isAnswered = false;
      showTip = false;
      if (currentIndex < quizData.length) {
        startBonusTimer();
      } else {
        navigateToResults();
      }
    });
  }

  void resetOptionColors() {
    optionColors = List.generate(6, (index) => Colors.white);
  }

  void navigateToResults() async {
    final baseScore = correctAnswers * 100;
    final totalScore = baseScore + totalBonusPoints;
    final coinsEarned = correctAnswers * 10 + (totalBonusPoints ~/ 10);

    //final authRepo = Get.find<AuthenticationRepository>();
    //final userId = authRepo.firebaseUser.value?.uid;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedResultsScreen(
          category: widget.category,
          preferences: widget.preferences,
          quizId: quizData[0].id.toString(),
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          totalQuestions: quizData.length,
          bonusPoints: totalBonusPoints,
          totalScore: totalScore,
          coinsEarned: coinsEarned,
          userAnswers: userAnswers,
          timeSpent: (quizData.length * 60) - seconds,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Color(widget.category.color),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20.h),
              Text(
                'Loading ${widget.category.name} Quiz...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Preparing ${widget.preferences.limit} questions',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: Color(widget.category.color),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Quiz Loading Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(widget.category.color),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Go Back'),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: initializeQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    final quiz = quizData[currentIndex];

    if (!isLoadingOptions) {
      optionsList = [
        quiz.answers.answerA,
        quiz.answers.answerB,
        quiz.answers.answerC,
        quiz.answers.answerD,
        quiz.answers.answerE,
        quiz.answers.answerF,
      ].where((element) => element.isNotEmpty).cast<String>().toList();
      optionsList.shuffle();
      isLoadingOptions = true;
    }

    String correctAnswerText = '';
    if (quiz.correctAnswers.answerACorrect == 'true') {
      correctAnswerText = quiz.answers.answerA;
    }
    if (quiz.correctAnswers.answerBCorrect == 'true') {
      correctAnswerText = quiz.answers.answerB;
    }
    if (quiz.correctAnswers.answerCCorrect == 'true') {
      correctAnswerText = quiz.answers.answerC;
    }
    if (quiz.correctAnswers.answerDCorrect == 'true') {
      correctAnswerText = quiz.answers.answerD;
    }
    if (quiz.correctAnswers.answerECorrect == 'true') {
      correctAnswerText = quiz.answers.answerE;
    }
    if (quiz.correctAnswers.answerFCorrect == 'true') {
      correctAnswerText = quiz.answers.answerF;
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(widget.category.color),
              Color(widget.category.color).withValues(alpha: 0.8),
              Color(widget.category.color).withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 20.h),
                _buildProgressSection(),
                SizedBox(height: 20.h),
                _buildQuestionSection(quiz),
                SizedBox(height: 20.h),
                _buildOptionsSection(quiz, correctAnswerText),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _showExitDialog(),
          icon: const Icon(Icons.close, color: Colors.white, size: 30),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            widget.category.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildBonusWidget(),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentIndex + 1} of ${quizData.length}',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                widget.preferences.difficulty,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        LinearProgressIndicator(
          value: (currentIndex + 1) / quizData.length,
          backgroundColor: Colors.white.withValues(alpha: 0.3),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(QuizModel quiz) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quiz.question,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (quiz.description != null && quiz.description!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Text(
                quiz.description!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (showTip && quiz.tip != null && quiz.tip!.isNotEmpty) ...[
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      quiz.tip!,
                      style: TextStyle(
                        color: Colors.amber.shade100,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsSection(QuizModel quiz, String correctAnswerText) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: optionsList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: isAnswered
              ? null
              : () {
                  setState(() {
                    isAnswered = true;

                    final userAnswer = {
                      'question': quiz.question,
                      'description': quiz.description,
                      'tip': quiz.tip,
                      'explanation': quiz.explanation,
                      'userAnswer': optionsList[index],
                      'correctAnswer': correctAnswerText,
                      'isCorrect': optionsList[index] == correctAnswerText,
                      'bonusPoints': currentBonusPoints,
                      'options': optionsList,
                    };
                    userAnswers.add(userAnswer);

                    if (optionsList[index] == correctAnswerText) {
                      optionColors[index] = Colors.green;
                      correctAnswers++;
                      totalBonusPoints += currentBonusPoints;
                    } else {
                      optionColors[index] = Colors.red;
                      incorrectAnswers++;
                    }
                  });

                  if (quiz.tip != null && quiz.tip!.isNotEmpty) {
                    setState(() {
                      showTip = true;
                    });
                  }

                  Future.delayed(const Duration(milliseconds: 1500), () {
                    if (currentIndex < quizData.length - 1) {
                      gotoNextQuestion();
                    } else {
                      timer!.cancel();
                      navigateToResults();
                    }
                  });
                },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: optionColors[index],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              optionsList[index],
              style: TextStyle(
                fontSize: 16.sp,
                color: optionColors[index] == Colors.white
                    ? Colors.black87
                    : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBonusWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '$currentBonusPoints',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'BONUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: currentBonusPoints / 60,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
            'Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              timer?.cancel();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit quiz
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAPIFailureWithFallback(String errorMessage) async {
    // Show dialog asking user if they want to use AI-generated questions
    final shouldUseAI = await _showAPIFailureDialog(errorMessage);

    if (shouldUseAI) {
      await _generateAIFallbackQuestions();
    } else {
      setState(() {
        hasError = true;
        errorMessage =
            'Quiz API is currently unavailable. Please try again later.';
        isLoading = false;
      });
    }
  }

  Future<bool> _showAPIFailureDialog(String errorMessage) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'API Unavailable',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The quiz service is temporarily unavailable:',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.red.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Would you like to generate quiz questions using AI instead?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.blue, size: 16.sp),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'AI will generate ${widget.preferences.limit} custom ${widget.category.name} questions',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('Use AI Quiz'),
                    ],
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _generateAIFallbackQuestions() async {
    try {
      // Initialize Gemini AI service if not already done
      if (!Get.isRegistered<GeminiAIService>()) {
        Get.put(GeminiAIService());
      }

      final geminiService = Get.find<GeminiAIService>();

      // Generate quiz questions using Gemini AI
      final quizQuestions = await geminiService.generateCustomQuiz(
        topic: widget.category.name,
        difficulty: widget.preferences.difficulty,
        numberOfQuestions: widget.preferences.limit,
        specificRequirements:
            'Create engaging multiple-choice questions suitable for a general audience',
        language: 'English',
      );

      if (quizQuestions.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage =
              'Failed to generate AI questions. Please try again later.';
          isLoading = false;
        });
        return;
      }

      quizData = quizQuestions;
      setState(() {
        isLoading = false;
      });

      // Show success message
      Get.snackbar(
        'AI Quiz Generated! 🤖',
        'Successfully created ${quizQuestions.length} custom questions for ${widget.category.name}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );

      startBonusTimer();
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage =
            'Failed to generate AI questions. Please try again later.';
        isLoading = false;
      });
      debugPrint('AI quiz generation error: $e');
    }
  }
}
