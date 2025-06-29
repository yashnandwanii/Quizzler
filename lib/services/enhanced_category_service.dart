import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';

class EnhancedCategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize enhanced categories with QuizAPI.io mapping
  static Future<void> initializeEnhancedCategories() async {
    try {
      final categoriesRef = _firestore.collection('categories');
      
      // Check if categories already exist
      final snapshot = await categoriesRef.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return; // Categories already initialized
      }

      // Enhanced categories with QuizAPI.io mapping
      final enhancedCategories = [
        QuizCategory(
          id: 'linux',
          name: 'Linux',
          description: 'Linux commands, system administration, and bash scripting',
          iconPath: 'assets/computer-science.png',
          color: 0xFF4CAF50,
          difficulty: 'Medium',
          quizCount: 0,
          isActive: true,
          availableTags: ['bash', 'terminal', 'commands', 'filesystem', 'permissions'],
          apiCategory: 'Linux',
        ),
        QuizCategory(
          id: 'devops',
          name: 'DevOps',
          description: 'DevOps practices, CI/CD, automation, and infrastructure',
          iconPath: 'assets/gadgets.png',
          color: 0xFF2196F3,
          difficulty: 'Hard',
          quizCount: 0,
          isActive: true,
          availableTags: ['docker', 'kubernetes', 'ci/cd', 'automation', 'monitoring'],
          apiCategory: 'DevOps',
        ),
        QuizCategory(
          id: 'networking',
          name: 'Networking',
          description: 'Network protocols, security, and infrastructure',
          iconPath: 'assets/physics.png',
          color: 0xFFFF9800,
          difficulty: 'Medium',
          quizCount: 0,
          isActive: true,
          availableTags: ['tcp/ip', 'routing', 'protocols', 'security', 'wireless'],
          apiCategory: 'Networking',
        ),
        QuizCategory(
          id: 'programming',
          name: 'Programming',
          description: 'Programming languages, algorithms, and software development',
          iconPath: 'assets/computer-science.png',
          color: 0xFF9C27B0,
          difficulty: 'Medium',
          quizCount: 0,
          isActive: true,
          availableTags: ['php', 'javascript', 'python', 'algorithms', 'data-structures'],
          apiCategory: 'Code',
        ),
        QuizCategory(
          id: 'cloud',
          name: 'Cloud Computing',
          description: 'Cloud platforms, services, and architecture',
          iconPath: 'assets/gadgets.png',
          color: 0xFF795548,
          difficulty: 'Hard',
          quizCount: 0,
          isActive: true,
          availableTags: ['aws', 'azure', 'gcp', 'serverless', 'storage'],
          apiCategory: 'Cloud',
        ),
        QuizCategory(
          id: 'docker',
          name: 'Docker',
          description: 'Containerization, Docker commands, and best practices',
          iconPath: 'assets/gadgets.png',
          color: 0xFFE91E63,
          difficulty: 'Medium',
          quizCount: 0,
          isActive: true,
          availableTags: ['containers', 'images', 'compose', 'volumes', 'networking'],
          apiCategory: 'Docker',
        ),
        QuizCategory(
          id: 'kubernetes',
          name: 'Kubernetes',
          description: 'Container orchestration, K8s concepts, and management',
          iconPath: 'assets/gadgets.png',
          color: 0xFF673AB7,
          difficulty: 'Hard',
          quizCount: 0,
          isActive: true,
          availableTags: ['pods', 'services', 'deployments', 'ingress', 'configmaps'],
          apiCategory: 'Kubernetes',
        ),
        QuizCategory(
          id: 'general_knowledge',
          name: 'General Knowledge',
          description: 'Mixed topics and general technology knowledge',
          iconPath: 'assets/school.png',
          color: 0xFF607D8B,
          difficulty: 'Easy',
          quizCount: 0,
          isActive: true,
          availableTags: ['basics', 'fundamentals', 'concepts', 'theory'],
          apiCategory: '', // No specific category for general knowledge
        ),
      ];

      // Add categories to Firestore
      for (var category in enhancedCategories) {
        await categoriesRef.doc(category.id).set({
          ...category.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('Enhanced categories initialized successfully');
    } catch (e) {
      print('Error initializing enhanced categories: $e');
    }
  }

  // Get all active categories
  static Future<List<QuizCategory>> getEnhancedCategories() async {
    try {
      final query = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizCategory.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching enhanced categories: $e');
      return [];
    }
  }

  // Get category by ID
  static Future<QuizCategory?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return QuizCategory.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  // Update quiz count for category
  static Future<void> updateQuizCount(String categoryId, int increment) async {
    try {
      await _firestore.collection('categories').doc(categoryId).update({
        'quizCount': FieldValue.increment(increment),
        'lastUsed': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating quiz count: $e');
    }
  }

  // Get categories by difficulty
  static Future<List<QuizCategory>> getCategoriesByDifficulty(String difficulty) async {
    try {
      final query = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .where('difficulty', isEqualTo: difficulty)
          .orderBy('name')
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizCategory.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching categories by difficulty: $e');
      return [];
    }
  }

  // Search categories
  static Future<List<QuizCategory>> searchCategories(String query) async {
    try {
      final categories = await getEnhancedCategories();
      final lowercaseQuery = query.toLowerCase();
      
      return categories.where((category) {
        return category.name.toLowerCase().contains(lowercaseQuery) ||
               category.description.toLowerCase().contains(lowercaseQuery) ||
               category.availableTags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      print('Error searching categories: $e');
      return [];
    }
  }
}