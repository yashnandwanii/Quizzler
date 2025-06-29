import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/model/quiz_history_model.dart' as history;

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // USERS
  static Future<void> saveUserProfile(String userId, UserModel user) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({'profile': user.toJson()}, SetOptions(merge: true));
    await _firestore
        .collection('users')
        .doc(userId)
        .set({'coins': user.coins, 'rank': user.rank}, SetOptions(merge: true));
  }

  static Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists &&
        doc.data() != null &&
        doc.data()!.containsKey('profile')) {
      final profile = doc['profile'];
      return UserModel.fromJson({
        ...profile,
        'coins': doc['coins'] ?? 0,
        'rank': doc['rank'] ?? 0,
      });
    }
    return null;
  }

  static Future<void> updateUserCoins(String userId, int coins) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set({'coins': coins}, SetOptions(merge: true));
  }

  static Future<int> getUserCoins(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null && doc.data()!.containsKey('coins')) {
      return doc['coins'] ?? 0;
    }
    return 0;
  }

  static Future<void> addUserAchievement(
      String userId, String achievement) async {
    await _firestore.collection('users').doc(userId).update({
      'achievements': FieldValue.arrayUnion([achievement])
    });
  }

  static Future<List<String>> getUserAchievements(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists &&
        doc.data() != null &&
        doc.data()!.containsKey('achievements')) {
      return List<String>.from(doc['achievements'] ?? []);
    }
    return [];
  }

  // QUIZ HISTORY
  static Future<void> addQuizHistory(
      String userId, history.QuizHistory history) async {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc();
    await ref.set(history.toMap());
  }

  static Future<List<history.QuizHistory>> getUserQuizHistory(String userId,
      {int limit = 10}) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return query.docs
        .map((doc) => history.QuizHistory.fromMap(doc.data()))
        .toList();
  }

  // QUIZZES
  static Future<void> saveQuizMeta(String quizId, QuizMetaModel meta) async {
    await _firestore.collection('quizzes').doc(quizId).set({
      'metadata': {
        'title': meta.title,
        'category': meta.category,
        'imageUrl': meta.imageUrl,
      }
    }, SetOptions(merge: true));
  }

  static Future<QuizMetaModel?> getQuizMeta(String quizId) async {
    final doc = await _firestore.collection('quizzes').doc(quizId).get();
    if (doc.exists &&
        doc.data() != null &&
        doc.data()!.containsKey('metadata')) {
      return QuizMetaModel.fromMap(doc['metadata']);
    }
    return null;
  }

  static Future<void> saveQuizQuestions(
      String quizId, List<QuestionModel> questions) async {
    await _firestore.collection('quizzes').doc(quizId).set(
        {'questions': questions.map((q) => q.toJson()).toList()},
        SetOptions(merge: true));
  }

  static Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    final doc = await _firestore.collection('quizzes').doc(quizId).get();
    if (doc.exists &&
        doc.data() != null &&
        doc.data()!.containsKey('questions')) {
      return List<Map<String, dynamic>>.from(doc['questions'])
          .map((q) => QuestionModel.fromJson(q))
          .toList();
    }
    return [];
  }

  // CATEGORIES
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final query = await _firestore.collection('categories').get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  // LEADERBOARDS
  static Future<Map<String, dynamic>> getLeaderboard(
      String leaderboardId) async {
    final doc =
        await _firestore.collection('leaderboards').doc(leaderboardId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    return {};
  }
}
