import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:quizzler/services/gemini_ai_service.dart';

void main() {
  group('GeminiAI Service Tests', () {
    late GeminiAIService geminiService;

    setUp(() {
      // Initialize GetX for testing
      Get.testMode = true;
      geminiService = GeminiAIService();
    });

    tearDown(() {
      Get.reset();
    });

    test('should initialize service without errors', () {
      expect(geminiService, isNotNull);
      expect(geminiService.isLoading.value, isFalse);
      expect(geminiService.error.value, isEmpty);
    });

    test('should validate quiz generation parameters', () {
      // Test valid parameters
      expect(
          geminiService.validateQuizParameters(
            topic: 'Flutter Development',
            difficulty: 'medium',
            numberOfQuestions: 5,
          ),
          isTrue);

      // Test empty topic
      expect(
          geminiService.validateQuizParameters(
            topic: '',
            difficulty: 'easy',
            numberOfQuestions: 5,
          ),
          isFalse);
      expect(geminiService.error.value, isNotEmpty);

      // Reset error for next test
      geminiService.error.value = '';

      // Test invalid question count
      expect(
          geminiService.validateQuizParameters(
            topic: 'Science',
            difficulty: 'easy',
            numberOfQuestions: 0,
          ),
          isFalse);
      expect(geminiService.error.value, isNotEmpty);

      // Reset error for next test
      geminiService.error.value = '';

      // Test invalid question count (too high)
      expect(
          geminiService.validateQuizParameters(
            topic: 'Science',
            difficulty: 'easy',
            numberOfQuestions: 51,
          ),
          isFalse);
      expect(geminiService.error.value, isNotEmpty);

      // Reset error for next test
      geminiService.error.value = '';

      // Test invalid difficulty
      expect(
          geminiService.validateQuizParameters(
            topic: 'Science',
            difficulty: 'invalid',
            numberOfQuestions: 5,
          ),
          isFalse);
      expect(geminiService.error.value, isNotEmpty);
    });

    test('should handle reactive properties correctly', () {
      expect(geminiService.isLoading, isA<RxBool>());
      expect(geminiService.error, isA<RxString>());

      // Test initial values
      expect(geminiService.isLoading.value, isFalse);
      expect(geminiService.error.value, isEmpty);

      // Test reactivity
      geminiService.isLoading.value = true;
      expect(geminiService.isLoading.value, isTrue);

      geminiService.error.value = 'Test error';
      expect(geminiService.error.value, equals('Test error'));
    });
  });
}
