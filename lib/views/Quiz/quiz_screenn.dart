import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/services/quiz_api_service.dart';
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:wallpaper_app/views/Results/results_screen.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';

class QuizScreenn extends StatefulWidget {
  final String category;
  final String difficulty;

  const QuizScreenn(
      {super.key, required this.category, required this.difficulty});

  @override
  State<QuizScreenn> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreenn> {
  late List<QuizModel> quizData;
  bool isLoading = true;

  int currentIndex = 0;
  int seconds = 60;
  Timer? timer;
  int correctAnswers = 0;
  int incorrectAnswers = 0;
  bool isLoadingOptions = false;
  int totalBonusPoints = 0;
  int currentBonusPoints = 60; // Starting bonus points
  bool isAnswered = false;
  bool showTip = false;

  List<String> optionsList = [];
  List<Color> optionColors = List.generate(6, (index) => Colors.white);

  // Store user answers and quiz data for results screen
  List<Map<String, dynamic>> userAnswers = [];

  @override
  void initState() {
    super.initState();
    initializeRandomQuiz();
  }

  Future<void> initializeRandomQuiz() async {
    quizData = await QuizApiService.fetchRandomQuizzes(
      limit: 10,
    );
    setState(() {
      isLoading = false;
    });
    startBonusTimer();
  }

  Future<void> initializeQuiz() async {
    quizData = await QuizApiService.fetchQuizzes(
      category: widget.category,
      difficulty: widget.difficulty,
      limit: 10,
    );
    setState(() {
      isLoading = false;
    });
    startBonusTimer();
  }

  void startBonusTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        gotoNextQuestion();
      } else {
        setState(() {
          seconds--;
          // Decrease bonus points every second
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
      currentBonusPoints = 60; // Reset bonus points for next question
      isAnswered = false;
      showTip = false; // Reset tip display
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
    // Calculate final scores
    final baseScore = correctAnswers * 100;
    final totalScore = baseScore + totalBonusPoints;
    final coinsEarned = correctAnswers * 10 + (totalBonusPoints ~/ 10);

    // Get current user
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    if (userId != null) {
      // Save quiz history - this will be done in ResultsScreen
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          quizId: quizData[0].id.toString(), // Pass the real quizId
          correctAnswers: correctAnswers,
          incorrectAnswers: incorrectAnswers,
          totalQuestions: quizData.length,
          bonusPoints: totalBonusPoints,
          totalScore: totalScore,
          coinsEarned: coinsEarned,
          userAnswers: userAnswers,
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 57, 92, 125),
              Color.fromARGB(255, 22, 91, 88),
              Color.fromARGB(199, 22, 91, 88),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                    ),
                    _buildBonusWidget(),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Question ${currentIndex + 1} of ${quizData.length}',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                SizedBox(height: 20.h),
                Text(
                  quiz.question,
                  style: TextStyle(color: Colors.white, fontSize: 18.sp),
                ),
                if (quiz.description != null &&
                    quiz.description!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      quiz.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
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
                      color: Colors.amber.withOpacity(0.2),
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
                SizedBox(height: 20.h),
                ListView.builder(
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

                                // Store user answer data
                                final userAnswer = {
                                  'question': quiz.question,
                                  'description': quiz.description,
                                  'tip': quiz.tip,
                                  'explanation': quiz.explanation,
                                  'userAnswer': optionsList[index],
                                  'correctAnswer': correctAnswerText,
                                  'isCorrect':
                                      optionsList[index] == correctAnswerText,
                                  'bonusPoints': currentBonusPoints,
                                  'options': optionsList,
                                };
                                userAnswers.add(userAnswer);

                                if (optionsList[index] == correctAnswerText) {
                                  optionColors[index] = Colors.green;
                                  correctAnswers++;
                                  // Add current bonus points to total
                                  totalBonusPoints += currentBonusPoints;
                                } else {
                                  optionColors[index] = Colors.red;
                                  incorrectAnswers++;
                                }
                              });

                              // Show tip after answering
                              if (quiz.tip != null && quiz.tip!.isNotEmpty) {
                                setState(() {
                                  showTip = true;
                                });
                              }

                              Future.delayed(const Duration(milliseconds: 1500),
                                  () {
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: optionColors[index],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          optionsList[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBonusWidget() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
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
              color: Colors.grey.withOpacity(0.3),
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
}
