import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/Results/widgets/header_section.dart';
import 'package:wallpaper_app/views/Results/widgets/question_review_section.dart';
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/services/firestore_service.dart';
import 'package:wallpaper_app/model/quiz_history_model.dart' as history;
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;
  final int bonusPoints;
  final int totalScore;
  final int coinsEarned;
  final List<Map<String, dynamic>> userAnswers;
  final String quizId;

  const ResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
    required this.bonusPoints,
    required this.totalScore,
    required this.coinsEarned,
    required this.userAnswers,
    required this.quizId,
  });

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _saveQuizResultAndUpdateRank();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scorePercentage =
        (widget.correctAnswers / widget.totalQuestions) * 100;

    String feedback;
    if (scorePercentage == 100) {
      feedback = "🎉 Perfect Score! You're a Quiz Master!";
    } else if (scorePercentage >= 75) {
      feedback = "👏 Great job! You're getting there!";
    } else if (scorePercentage >= 50) {
      feedback = "💪 Good effort! Keep practicing!";
    } else {
      feedback = "🔥 Don't give up! Try again!";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quiz Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.shade100,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent.shade100,
              const Color.fromARGB(255, 22, 91, 88),
              const Color.fromARGB(199, 22, 91, 88),
            ],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Section
                  HeaderSection(feedback: feedback),

                  // Score Summary Cards
                  _buildScoreSummary(),

                  // Question Review Section
                  QuestionReviewSection(widget: widget),

                  // Play Again Button
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const QuizSplashScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Play Again',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.yellow,
                  Colors.purple
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coins earned
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 116, 11, 186),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on,
                    color: Colors.amber, size: 24),
                SizedBox(width: 8.w),
                Text(
                  'You earned ${widget.coinsEarned} coins!',
                  style: GoogleFonts.robotoMono(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Score grid
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Correct',
                  widget.correctAnswers.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildScoreCard(
                  'Incorrect',
                  widget.incorrectAnswers.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Score',
                  '${((widget.correctAnswers / widget.totalQuestions) * 100).toStringAsFixed(1)}%',
                  Colors.orangeAccent,
                  Icons.assessment,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildScoreCard(
                  'Bonus',
                  '${widget.bonusPoints}',
                  Colors.amber,
                  Icons.star,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildScoreCard(
            'Total Score',
            '${widget.totalScore}',
            Colors.purple,
            Icons.emoji_events,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color color, IconData icon,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveQuizResultAndUpdateRank() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;
    // Save quiz history
    final quizHistory = history.QuizHistory(
      quizId: widget.quizId,
      score: widget.totalScore,
      total: widget.totalQuestions,
      duration: '00:00:00',
      date: DateTime.now(),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .add(quizHistory.toMap());
    // Update coins
    final currentCoins = await FirestoreService.getUserCoins(userId);
    await FirestoreService.updateUserCoins(
        userId, currentCoins + widget.coinsEarned);
    // Recalculate and update user rank
    await _recalculateAndUpdateRanks();
  }

  Future<void> _recalculateAndUpdateRanks() async {
    // Fetch all users and their coins
    final query = await FirebaseFirestore.instance.collection('users').get();
    final users = <Map<String, dynamic>>[];
    for (final doc in query.docs) {
      if (doc.data().containsKey('profile')) {
        users.add({
          'id': doc.id,
          'coins': doc['coins'] ?? 0,
        });
      }
    }
    // Sort users by coins descending
    users.sort((a, b) => (b['coins'] as int).compareTo(a['coins'] as int));
    // Assign ranks and update Firestore
    for (int i = 0; i < users.length; i++) {
      final userId = users[i]['id'];
      final rank = i + 1;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({'rank': rank}, SetOptions(merge: true));
    }
  }
}
