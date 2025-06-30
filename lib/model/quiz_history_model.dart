import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistory {
  final String quizId;
  final int score;
  final int total;
  final String duration;
  final DateTime date;

  QuizHistory({
    required this.quizId,
    required this.score,
    required this.total,
    required this.duration,
    required this.date,
  });

  factory QuizHistory.fromMap(Map<String, dynamic> map) {
    return QuizHistory(
      quizId: map['quizId'] ?? '',
      score: map['score'] ?? 0,
      total: map['total'] ?? 0,
      duration: map['duration'] ?? '',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'score': score,
      'total': total,
      'duration': duration,
      'date': Timestamp.fromDate(date),
    };
  }
}
