import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/Results/widgets/question_review_card.dart';

class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.answer,
    required this.questionNumber,
  });

  final Map<String, dynamic> answer;
  final int questionNumber;

  @override
  Widget build(BuildContext context) {
    return QuestionReviewCard(
      questionNumber: questionNumber,
      question: answer['question'],
      description: answer['description'],
      userAnswer: answer['userAnswer'],
      correctAnswer: answer['correctAnswer'],
      isCorrect: answer['isCorrect'],
      explanation: answer['explanation'],
      tip: answer['tip'],
      options: List<String>.from(answer['options']),
      bonusPoints: answer['bonusPoints'],
    );
  }
}
