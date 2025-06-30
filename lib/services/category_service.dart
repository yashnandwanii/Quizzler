import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize default categories
  static Future<void> initializeCategories() async {
    try {
      final categoriesRef = _firestore.collection('categories');

      // Check if categories already exist
      final snapshot = await categoriesRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return; // Categories already initialized
      }

      // Default categories
      final defaultCategories = [
        {
          'id': 'general_knowledge',
          'name': 'General Knowledge',
          'description': 'Test your general knowledge across various topics',
          'iconPath': 'assets/school.png',
          'color': 0xFF4CAF50,
          'difficulty': 'Easy',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'computer_science',
          'name': 'Computer Science',
          'description': 'Programming, algorithms, and technology',
          'iconPath': 'assets/computer-science.png',
          'color': 0xFF2196F3,
          'difficulty': 'Medium',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'mathematics',
          'name': 'Mathematics',
          'description': 'Numbers, equations, and mathematical concepts',
          'iconPath': 'assets/maths.png',
          'color': 0xFFFF9800,
          'difficulty': 'Hard',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'science',
          'name': 'Science',
          'description': 'Physics, chemistry, biology, and more',
          'iconPath': 'assets/physics.png',
          'color': 0xFF9C27B0,
          'difficulty': 'Medium',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'history',
          'name': 'History',
          'description': 'Historical events, figures, and civilizations',
          'iconPath': 'assets/history.png',
          'color': 0xFF795548,
          'difficulty': 'Medium',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'sports',
          'name': 'Sports',
          'description': 'Sports trivia, athletes, and competitions',
          'iconPath': 'assets/sports.png',
          'color': 0xFFE91E63,
          'difficulty': 'Easy',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'animals',
          'name': 'Animals',
          'description': 'Wildlife, pets, and animal kingdom',
          'iconPath': 'assets/animals.png',
          'color': 0xFF4CAF50,
          'difficulty': 'Easy',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'music',
          'name': 'Music',
          'description': 'Artists, songs, and musical knowledge',
          'iconPath': 'assets/music.png',
          'color': 0xFF673AB7,
          'difficulty': 'Medium',
          'quizCount': 0,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      // Add categories to Firestore
      for (var category in defaultCategories) {
        await categoriesRef.doc(category['id'] as String).set(category);
      }

      debugPrint('Categories initialized successfully');
    } catch (e) {
      debugPrint('Error initializing categories: $e');
    }
  }

  // Get all active categories
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final query = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  // Get category by ID
  static Future<Map<String, dynamic>?> getCategoryById(
      String categoryId) async {
    try {
      final doc =
          await _firestore.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching category: $e');
      return null;
    }
  }

  // Update quiz count for category
  static Future<void> updateQuizCount(String categoryId, int increment) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'quizCount': FieldValue.increment(increment),
      });
    } catch (e) {
      debugPrint('Error updating quiz count: $e');
    }
  }

  // Add new category
  static Future<void> addCategory(Map<String, dynamic> categoryData) async {
    try {
      categoryData['createdAt'] = FieldValue.serverTimestamp();
      categoryData['isActive'] = true;
      categoryData['quizCount'] = 0;

      await _firestore.collection('categories').add(categoryData);
    } catch (e) {
      debugPrint('Error adding category: $e');
    }
  }
}
