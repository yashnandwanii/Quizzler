import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Custom exception classes for better error handling
class ApiServerException implements Exception {
  final String message;
  ApiServerException(this.message);
  @override
  String toString() => message;
}

class ApiKeyException implements Exception {
  final String message;
  ApiKeyException(this.message);
  @override
  String toString() => message;
}

class RateLimitException implements Exception {
  final String message;
  RateLimitException(this.message);
  @override
  String toString() => message;
}

class EnhancedQuizApiService {
  static const String baseUrl = "https://quizapi.io/api/v1/questions";
  static final String apiKey = dotenv.env['QUIZ_API_KEY'] ?? '';

  // Fetch quizzes with enhanced parameters
  static Future<List<QuizModel>> fetchEnhancedQuizzes({
    String? category,
    String? difficulty,
    int limit = 10,
    List<String>? tags,
    bool singleAnswerOnly = false,
  }) async {
    try {
      final queryParams = <String, String>{
        "apiKey": apiKey,
        "limit": limit.toString(),
      };

      // Add category if specified
      if (category != null && category.isNotEmpty) {
        queryParams["category"] = category;
      }

      // Add difficulty if specified
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams["difficulty"] = difficulty.toLowerCase();
      }

      // Add tags if specified
      if (tags != null && tags.isNotEmpty) {
        queryParams["tags"] = tags.join(',');
      }

      // Add single answer only filter
      if (singleAnswerOnly) {
        queryParams["single_answer_only"] = "true";
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      debugPrint("API Request URL: $uri");

      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException(
              'Request timeout. Quiz API is not responding.');
        },
      );
      debugPrint("API Response Status: ${response.statusCode}");
      debugPrint("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final quizzes = jsonData.map((e) => QuizModel.fromJson(e)).toList();

        // Filter out questions with empty answers if needed
        final filteredQuizzes = quizzes.where((quiz) {
          return quiz.answers.answerA.isNotEmpty ||
              quiz.answers.answerB.isNotEmpty ||
              quiz.answers.answerC.isNotEmpty ||
              quiz.answers.answerD.isNotEmpty;
        }).toList();

        return filteredQuizzes;
      } else if (response.statusCode == 502) {
        throw ApiServerException(
            "Quiz API service is temporarily unavailable (502 Bad Gateway). Please try again later or use AI-generated quiz option.");
      } else if (response.statusCode == 401) {
        throw ApiKeyException(
            "Invalid API key. Please check your configuration.");
      } else if (response.statusCode == 429) {
        throw RateLimitException(
            "API rate limit exceeded. Please wait a moment and try again.");
      } else {
        throw Exception(
            "Failed to load quizzes: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching enhanced quizzes: $e");
      rethrow;
    }
  }

  // Fetch quizzes using preferences
  static Future<List<QuizModel>> fetchQuizzesWithPreferences({
    required String category,
    required QuizPreferences preferences,
  }) async {
    return await fetchEnhancedQuizzes(
      category: category,
      difficulty: preferences.difficulty,
      limit: preferences.limit,
      tags: preferences.tags.isNotEmpty ? preferences.tags : null,
      singleAnswerOnly: preferences.singleAnswerOnly,
    );
  }

  // Fetch random quizzes with preferences
  static Future<List<QuizModel>> fetchRandomQuizzesWithPreferences({
    required QuizPreferences preferences,
  }) async {
    return await fetchEnhancedQuizzes(
      difficulty: preferences.difficulty,
      limit: preferences.limit,
      tags: preferences.tags.isNotEmpty ? preferences.tags : null,
      singleAnswerOnly: preferences.singleAnswerOnly,
    );
  }

  // Get available categories from API
  static List<String> getAvailableCategories() {
    return [
      'Linux',
      'DevOps',
      'Networking',
      'Programming',
      'Cloud',
      'Docker',
      'Kubernetes',
      'Code', // General programming
      'CMS',
      'SQL',
      'WordPress',
    ];
  }

  // Get available difficulties
  static List<String> getAvailableDifficulties() {
    return ['Easy', 'Medium', 'Hard'];
  }

  // Validate API key
  static Future<bool> validateApiKey() async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "apiKey": apiKey,
        "limit": "1",
      });

      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error validating API key: $e");
      return false;
    }
  }

  // Test API connection and key validity
  static Future<Map<String, dynamic>> testAPIConnection() async {
    try {
      final uri = Uri.parse(baseUrl).replace(queryParameters: {
        "apiKey": apiKey,
        "limit": "1",
      });

      final response = await http.get(uri);

      return {
        'isValid': response.statusCode == 200,
        'statusCode': response.statusCode,
        'message': response.statusCode == 200
            ? 'API connection successful'
            : response.statusCode == 401
                ? 'Invalid API key'
                : response.statusCode == 502
                    ? 'Quiz API service is temporarily unavailable (502 Bad Gateway)'
                    : 'API error: ${response.statusCode}',
        'hasApiKey': apiKey.isNotEmpty,
      };
    } catch (e) {
      return {
        'isValid': false,
        'statusCode': 0,
        'message': 'Network error: $e',
        'hasApiKey': apiKey.isNotEmpty,
      };
    }
  }

  // Check if we should use fallback (AI generation)
  static Future<bool> shouldUseFallback() async {
    final testResult = await testAPIConnection();
    return !testResult['isValid'];
  }
}
