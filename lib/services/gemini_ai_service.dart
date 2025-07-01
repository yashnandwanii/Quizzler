import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/model/quiz_model.dart';
import 'package:wallpaper_app/model/quiz_preferences_model.dart';

class GeminiAIService extends GetxController {
  late final GenerativeModel _model;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      error.value = 'GEMINI_API_KEY not found in environment variables';
      return;
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  /// Generate custom quiz questions using Gemini AI
  Future<List<QuizModel>> generateCustomQuiz({
    required String topic,
    required String difficulty,
    required int numberOfQuestions,
    String? specificRequirements,
    String? language,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final prompt = _buildQuizPrompt(
        topic: topic,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        specificRequirements: specificRequirements,
        language: language ?? 'English',
      );

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('No response received from AI');
      }

      return _parseAIResponse(response.text!);
    } catch (e) {
      error.value = 'Failed to generate quiz: $e';
      debugPrint('Gemini AI Error: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Build the prompt for Gemini AI
  String _buildQuizPrompt({
    required String topic,
    required String difficulty,
    required int numberOfQuestions,
    String? specificRequirements,
    required String language,
  }) {
    return '''
Create $numberOfQuestions multiple-choice quiz questions about "$topic" with $difficulty difficulty level in $language language.

STRICT FORMAT REQUIREMENTS:
- Return ONLY a valid JSON array that matches the QuizModel structure
- Each question must have exactly 6 answer options (answer_a through answer_f), but only use first 4
- Include explanations and tips for each question
- Questions should be appropriate for $difficulty level
- Set multiple_correct_answers to "false" for all questions

${specificRequirements != null ? 'Additional Requirements: $specificRequirements' : ''}

Required JSON format (must match QuizModel structure exactly):
[
  {
    "id": 1001,
    "question": "What is the main concept of object-oriented programming?",
    "description": "This question tests your understanding of OOP fundamentals",
    "tip": "Think about the core principles that make OOP different from procedural programming",
    "answers": {
      "answer_a": "Encapsulation and inheritance",
      "answer_b": "Only functions and procedures", 
      "answer_c": "Global variables only",
      "answer_d": "Linear code execution",
      "answer_e": "",
      "answer_f": ""
    },
    "multiple_correct_answers": "false",
    "correct_answers": {
      "answer_a_correct": "true",
      "answer_b_correct": "false",
      "answer_c_correct": "false",
      "answer_d_correct": "false",
      "answer_e_correct": "false",
      "answer_f_correct": "false"
    },
    "explanation": "Object-oriented programming is built on principles like encapsulation, inheritance, and polymorphism.",
    "tags": [{"name": "$topic"}],
    "category": "$topic",
    "difficulty": "$difficulty"
  }
]

Guidelines:
- Use incremental IDs starting from 1001
- Make questions engaging and educational
- Ensure only one correct answer per question (set only one answer_X_correct to "true")
- Fill answer_a through answer_d with plausible options
- Leave answer_e and answer_f as empty strings
- Provide clear, helpful explanations and tips
- For $difficulty level: ${_getDifficultyGuidelines(difficulty)}
- Set tags as array with one object containing "name" field
- Set category to the topic
- Set difficulty to the provided difficulty level

Generate exactly $numberOfQuestions questions following this exact format:
''';
  }

  String _getDifficultyGuidelines(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Use basic concepts, straightforward questions, avoid tricky wording';
      case 'medium':
        return 'Include some analysis, moderate complexity, mix of recall and application';
      case 'hard':
        return 'Require deep understanding, critical thinking, complex scenarios';
      default:
        return 'Mix of easy, medium, and hard questions for varied challenge';
    }
  }

  /// Parse the AI response and convert directly to QuizModel objects
  List<QuizModel> _parseAIResponse(String response) {
    try {
      // Clean up the response to extract JSON
      String jsonString = response.trim();

      // Remove markdown formatting if present
      if (jsonString.startsWith('```json')) {
        jsonString = jsonString.substring(7);
      }
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.substring(3);
      }
      if (jsonString.endsWith('```')) {
        jsonString = jsonString.substring(0, jsonString.length - 3);
      }

      jsonString = jsonString.trim();

      // Parse the JSON
      final parsed = json.decode(jsonString);

      if (parsed is List) {
        return List<QuizModel>.from(
            parsed.map((json) => QuizModel.fromJson(json)));
      } else {
        throw Exception('Response is not a valid JSON array');
      }
    } catch (e) {
      debugPrint('JSON Parsing Error: $e');
      debugPrint('Raw Response: $response');
      throw Exception('Failed to parse AI response: $e');
    }
  }

  /// Generate quiz suggestions based on user interests
  Future<List<String>> generateTopicSuggestions(String userInput) async {
    try {
      if (userInput.isEmpty) return _getDefaultSuggestions();

      final prompt = '''
Based on the input "$userInput", suggest 5 related quiz topics that would be interesting and educational.
Return only a JSON array of topic names, nothing else.
Example format: ["Topic 1", "Topic 2", "Topic 3", "Topic 4", "Topic 5"]
Make suggestions specific and engaging.
''';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        final suggestions = json.decode(response.text!) as List;
        return suggestions.cast<String>();
      }

      return _getDefaultSuggestions();
    } catch (e) {
      debugPrint('Error generating suggestions: $e');
      return _getDefaultSuggestions();
    }
  }

  List<String> _getDefaultSuggestions() {
    return [
      'General Knowledge',
      'Science & Technology',
      'History & Geography',
      'Arts & Literature',
      'Sports & Entertainment',
    ];
  }

  /// Validate quiz generation parameters
  bool validateQuizParameters({
    required String topic,
    required String difficulty,
    required int numberOfQuestions,
  }) {
    if (topic.trim().isEmpty) {
      error.value = 'Please enter a topic';
      return false;
    }

    if (numberOfQuestions < 1 || numberOfQuestions > 50) {
      error.value = 'Number of questions must be between 1 and 50';
      return false;
    }

    final validDifficulties = ['easy', 'medium', 'hard', 'mixed'];
    if (!validDifficulties.contains(difficulty.toLowerCase())) {
      error.value = 'Please select a valid difficulty level';
      return false;
    }

    return true;
  }

  /// Create a QuizCategory for AI-generated quiz
  QuizCategory createAIQuizCategory(String topic) {
    return QuizCategory(
      id: 'ai_generated_$topic',
      name: topic,
      iconPath: 'assets/computer-science.png',
      color: 0xFF2196F3,
      difficulty: 'Mixed',
      quizCount: 0,
      isActive: true,
      availableTags: [topic.toLowerCase()],
      apiCategory: 'ai_generated',
    );
  }

  /// Create QuizPreferences for AI-generated quiz
  QuizPreferences createAIQuizPreferences({
    required int numberOfQuestions,
    required String difficulty,
  }) {
    return QuizPreferences(
      difficulty: difficulty,
      limit: numberOfQuestions,
      tags: const [],
      singleAnswerOnly: false,
      rememberPreferences: false,
    );
  }
}
