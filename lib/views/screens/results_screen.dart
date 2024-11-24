import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Import confetti package
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';

class ResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int incorrectAnswers;
  final int totalQuestions;

  const ResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.totalQuestions,
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
    _confettiController.play(); // Play confetti when the screen opens
  }

  @override
  void dispose() {
    _confettiController
        .dispose(); // Dispose the controller to free up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double scorePercentage =
        (widget.correctAnswers / widget.totalQuestions) * 100;

    // Determine feedback based on performance
    String feedback;
    if (scorePercentage == 100) {
      feedback = "Perfect! You're a Quiz Master!";
    } else if (scorePercentage >= 75) {
      feedback = "Great job! Almost there!";
    } else if (scorePercentage >= 50) {
      feedback = "Good effort! Keep practicing!";
    } else {
      feedback = "Don't give up! Try again!";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quiz Results",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black26,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black26,
              Colors.black87,
            ],
          ),
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Trophy image
                      const Image(
                        image: AssetImage('assets/trophy.png'),
                        height: 350,
                      ),
                      // Confetti widget
                      ConfettiWidget(
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
                    ],
                  ),
                  const Text(
                    'Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    feedback,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Results display
                  _buildResultCard(
                    label: 'Correct Answers',
                    value: widget.correctAnswers.toString(),
                    color: Colors.green,
                  ),
                  _buildResultCard(
                    label: 'Incorrect Answers',
                    value: widget.incorrectAnswers.toString(),
                    color: Colors.red,
                  ),
                  _buildResultCard(
                    label: 'Total Questions',
                    value: widget.totalQuestions.toString(),
                    color: Colors.blueAccent,
                  ),
                  _buildResultCard(
                    label: 'Score',
                    value: '${scorePercentage.toStringAsFixed(2)}%',
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 10),
                  // Play again button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      iconColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
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
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build result cards
  Widget _buildResultCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
