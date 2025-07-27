import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';

class QuizPreferencesService {
  static final GetStorage _storage = GetStorage();
  static const String _preferencesKey = 'quiz_preferences';

  // Save user preferences
  static Future<void> savePreferences(QuizPreferences preferences) async {
    try {
      await _storage.write(_preferencesKey, preferences.toJson());
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // Get user preferences
  static QuizPreferences getPreferences() {
    try {
      final data = _storage.read(_preferencesKey);
      if (data != null) {
        return QuizPreferences.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
    return const QuizPreferences(); // Return default preferences
  }

  // Clear preferences
  static Future<void> clearPreferences() async {
    try {
      await _storage.remove(_preferencesKey);
    } catch (e) {
      debugPrint('Error clearing preferences: $e');
    }
  }

  // Check if user has saved preferences
  static bool hasPreferences() {
    return _storage.hasData(_preferencesKey);
  }

  // Get available difficulties
  static List<String> getAvailableDifficulties() {
    return ['Easy', 'Medium', 'Hard'];
  }

  // Get available limits
  static List<int> getAvailableLimits() {
    return [5, 10, 15, 20];
  }

  // Get popular tags by category
  static Map<String, List<String>> getPopularTagsByCategory() {
    return {
      'Linux': ['bash', 'terminal', 'commands', 'filesystem', 'permissions'],
      'DevOps': ['docker', 'kubernetes', 'ci/cd', 'automation', 'monitoring'],
      'Networking': ['tcp/ip', 'routing', 'protocols', 'security', 'wireless'],
      'Programming': [
        'algorithms',
        'data-structures',
        'oop',
        'debugging',
        'testing'
      ],
      'Cloud': ['aws', 'azure', 'gcp', 'serverless', 'storage'],
      'Docker': ['containers', 'images', 'compose', 'volumes', 'networking'],
      'Kubernetes': [
        'pods',
        'services',
        'deployments',
        'ingress',
        'configmaps'
      ],
      'General': ['basics', 'fundamentals', 'concepts', 'theory', 'practice'],
    };
  }
}
