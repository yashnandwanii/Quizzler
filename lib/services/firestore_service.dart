import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzler/model/user_model.dart';
import 'package:quizzler/model/quiz_model.dart';

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

  static Future<void> updateUserProfileFields(
      String userId, Map<String, dynamic> fields) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .set(fields, SetOptions(merge: true));
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

  // QUIZ HISTORY (robust, with quizId and timestamp)
  static Future<void> addQuizHistory(
      String userId, String quizId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .doc(quizId)
        .set({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> getUserQuizHistory(String userId,
      {int limit = 10}) async {
    final query = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quiz_history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
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

  // LEADERBOARD
  static Future<void> addOrUpdateLeaderboardEntry(
      String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('LeaderBoard')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  static Future<void> recalculateLeaderboardRanks() async {
    final query = await _firestore
        .collection('LeaderBoard')
        .orderBy('totalScore', descending: true)
        .get();
    int rank = 1;
    for (final doc in query.docs) {
      await doc.reference.update({'rank': rank});
      rank++;
    }
  }

  static Future<Map<String, dynamic>?> getLeaderboardEntry(
      String userId) async {
    final doc = await _firestore.collection('LeaderBoard').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    return null;
  }
}
