class QuizPreferences {
  final String difficulty;
  final int limit;
  final List<String> tags;
  final bool singleAnswerOnly;
  final bool rememberPreferences;

  const QuizPreferences({
    this.difficulty = 'Easy',
    this.limit = 10,
    this.tags = const [],
    this.singleAnswerOnly = false,
    this.rememberPreferences = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'limit': limit,
      'tags': tags,
      'singleAnswerOnly': singleAnswerOnly,
      'rememberPreferences': rememberPreferences,
    };
  }

  factory QuizPreferences.fromJson(Map<String, dynamic> json) {
    return QuizPreferences(
      difficulty: json['difficulty'] ?? 'Easy',
      limit: json['limit'] ?? 10,
      tags: List<String>.from(json['tags'] ?? []),
      singleAnswerOnly: json['singleAnswerOnly'] ?? false,
      rememberPreferences: json['rememberPreferences'] ?? true,
    );
  }

  QuizPreferences copyWith({
    String? difficulty,
    int? limit,
    List<String>? tags,
    bool? singleAnswerOnly,
    bool? rememberPreferences,
  }) {
    return QuizPreferences(
      difficulty: difficulty ?? this.difficulty,
      limit: limit ?? this.limit,
      tags: tags ?? this.tags,
      singleAnswerOnly: singleAnswerOnly ?? this.singleAnswerOnly,
      rememberPreferences: rememberPreferences ?? this.rememberPreferences,
    );
  }
}

class QuizCategory {
  final String id;
  final String name;
  final String iconPath;
  final int color;
  final String difficulty;
  final int quizCount;
  final bool isActive;
  final List<String> availableTags;
  final String apiCategory; // For QuizAPI.io mapping

  const QuizCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    required this.difficulty,
    required this.quizCount,
    required this.isActive,
    required this.availableTags,
    required this.apiCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'color': color,
      'difficulty': difficulty,
      'quizCount': quizCount,
      'isActive': isActive,
      'availableTags': availableTags,
      'apiCategory': apiCategory,
    };
  }

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconPath: json['iconPath'] ?? '',
      color: json['color'] ?? 0xFF2196F3,
      difficulty: json['difficulty'] ?? 'Medium',
      quizCount: json['quizCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      availableTags: List<String>.from(json['availableTags'] ?? []),
      apiCategory: json['apiCategory'] ?? '',
    );
  }
}
