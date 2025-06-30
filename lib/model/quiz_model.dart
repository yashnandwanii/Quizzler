import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

List<QuizModel> quizModelFromJson(String str) =>
    List<QuizModel>.from(json.decode(str).map((x) => QuizModel.fromJson(x)));

String quizModelToJson(List<QuizModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class QuizModel {
  int id;
  String question;
  String? description;
  String? tip;
  Answers answers;
  String multipleCorrectAnswers;
  CorrectAnswers correctAnswers;
  String explanation;
  List<dynamic> tags;
  String category;
  String difficulty;

  QuizModel({
    required this.id,
    required this.question,
    required this.description,
    required this.answers,
    required this.multipleCorrectAnswers,
    required this.correctAnswers,
    required this.explanation,
    required this.tip,
    required this.tags,
    required this.category,
    required this.difficulty,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
        id: json["id"],
        question: json["question"] ?? "",
        description: json["description"] ?? "",
        answers: Answers.fromJson(json["answers"]),
        multipleCorrectAnswers: json["multiple_correct_answers"] ?? "false",
        correctAnswers: CorrectAnswers.fromJson(json["correct_answers"]),
        explanation: json["explanation"] ?? "",
        tip: json["tip"] ?? "",
        tags: List<dynamic>.from(json["tags"].map((x) => x["name"])),
        category: json["category"] ?? "",
        difficulty: json["difficulty"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "description": description,
        "answers": answers.toJson(),
        "multiple_correct_answers": multipleCorrectAnswers,
        "correct_answers": correctAnswers.toJson(),
        "explanation": explanation,
        "tip": tip,
        "tags": List<dynamic>.from(tags.map((x) => x)),
        "category": category,
        "difficulty": difficulty,
      };
}

class Answers {
  String answerA;
  String answerB;
  String answerC;
  String answerD;
  String answerE;
  String answerF;

  Answers({
    required this.answerA,
    required this.answerB,
    required this.answerC,
    required this.answerD,
    required this.answerE,
    required this.answerF,
  });

  factory Answers.fromJson(Map<String, dynamic> json) => Answers(
        answerA: json["answer_a"] ?? "",
        answerB: json["answer_b"] ?? "",
        answerC: json["answer_c"] ?? "",
        answerD: json["answer_d"] ?? "",
        answerE: json["answer_e"] ?? "",
        answerF: json["answer_f"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "answer_a": answerA,
        "answer_b": answerB,
        "answer_c": answerC,
        "answer_d": answerD,
        "answer_e": answerE,
        "answer_f": answerF,
      };
}

class CorrectAnswers {
  String answerACorrect;
  String answerBCorrect;
  String answerCCorrect;
  String answerDCorrect;
  String answerECorrect;
  String answerFCorrect;

  CorrectAnswers({
    required this.answerACorrect,
    required this.answerBCorrect,
    required this.answerCCorrect,
    required this.answerDCorrect,
    required this.answerECorrect,
    required this.answerFCorrect,
  });

  factory CorrectAnswers.fromJson(Map<String, dynamic> json) => CorrectAnswers(
        answerACorrect: json["answer_a_correct"],
        answerBCorrect: json["answer_b_correct"],
        answerCCorrect: json["answer_c_correct"],
        answerDCorrect: json["answer_d_correct"],
        answerECorrect: json["answer_e_correct"],
        answerFCorrect: json["answer_f_correct"],
      );

  Map<String, dynamic> toJson() => {
        "answer_a_correct": answerACorrect,
        "answer_b_correct": answerBCorrect,
        "answer_c_correct": answerCCorrect,
        "answer_d_correct": answerDCorrect,
        "answer_e_correct": answerECorrect,
        "answer_f_correct": answerFCorrect,
      };
}

class QuizScore {
  final String userId;
  final String userName;
  final String category;
  final String difficulty;
  final int correctAnswers;
  final int totalQuestions;
  final int baseScore;
  final int bonusPoints;
  final int totalScore;
  final int timeBonus;
  final DateTime timestamp;
  final int coinsEarned;

  QuizScore({
    required this.userId,
    required this.userName,
    required this.category,
    required this.difficulty,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.baseScore,
    required this.bonusPoints,
    required this.totalScore,
    required this.timeBonus,
    required this.timestamp,
    required this.coinsEarned,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'category': category,
      'difficulty': difficulty,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'baseScore': baseScore,
      'bonusPoints': bonusPoints,
      'totalScore': totalScore,
      'timeBonus': timeBonus,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'coinsEarned': coinsEarned,
    };
  }

  factory QuizScore.fromJson(Map<String, dynamic> json) {
    return QuizScore(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
      correctAnswers: json['correctAnswers'] ?? 0,
      totalQuestions: json['totalQuestions'] ?? 0,
      baseScore: json['baseScore'] ?? 0,
      bonusPoints: json['bonusPoints'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      timeBonus: json['timeBonus'] ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
      coinsEarned: json['coinsEarned'] ?? 0,
    );
  }
}

class QuizMetaModel {
  final String title;
  final String category;
  final String imageUrl;

  QuizMetaModel({
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  factory QuizMetaModel.fromMap(Map<String, dynamic> map) {
    return QuizMetaModel(
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class QuestionModel {
  final String question;
  final String? description;
  final String? tip;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuestionModel({
    required this.question,
    this.description,
    this.tip,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        question: json['question'],
        description: json['description'],
        tip: json['tip'],
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'],
        explanation: json['explanation'],
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'description': description,
        'tip': tip,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

class QuizHistory {
  final String quizId;
  final int score;
  final DateTime date;

  QuizHistory({
    required this.quizId,
    required this.score,
    required this.date,
  });

  factory QuizHistory.fromMap(Map<String, dynamic> map) {
    return QuizHistory(
      quizId: map['quizId'] ?? '',
      score: map['score'] ?? 0,
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}
