import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';
import 'package:quizzler/services/quiz_preferences_service.dart';
import 'package:quizzler/views/Quiz/enhanced_quiz_screen.dart';

class QuizPreferencesScreen extends StatefulWidget {
  final QuizCategory category;

  const QuizPreferencesScreen({super.key, required this.category});

  @override
  State<QuizPreferencesScreen> createState() => _QuizPreferencesScreenState();
}

class _QuizPreferencesScreenState extends State<QuizPreferencesScreen> {
  late QuizPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    // Load saved preferences or use defaults
    _preferences = QuizPreferencesService.getPreferences();

    // If no saved preferences, use category defaults
    if (!QuizPreferencesService.hasPreferences()) {
      _preferences = QuizPreferences(
        difficulty: widget.category.difficulty,
        limit: 10,
        tags: [],
        singleAnswerOnly: false,
        rememberPreferences: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Quiz Settings',
          style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(widget.category.color),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(),
            SizedBox(height: 20.h),
            _buildDifficultySection(),
            SizedBox(height: 20.h),
            _buildLimitSection(),
            SizedBox(height: 20.h),
            _buildTagsSection(),
            SizedBox(height: 20.h),
            _buildOptionsSection(),
            SizedBox(height: 20.h),
            _buildRememberPreferencesSection(),
            SizedBox(height: 30.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(widget.category.color),
            Color(widget.category.color).withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: widget.category.iconPath.isNotEmpty
                ? Image.asset(
                    widget.category.iconPath,
                    width: 40.w,
                    height: 40.h,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.quiz,
                        size: 32.sp,
                        color: Colors.white,
                      );
                    },
                  )
                : Icon(
                    Icons.quiz,
                    size: 32.sp,
                    color: Colors.white,
                  ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.category.apiCategory,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySection() {
    return _buildSection(
      title: 'Difficulty Level',
      icon: Icons.trending_up,
      child: Column(
        children: QuizPreferencesService.getAvailableDifficulties()
            .map((difficulty) => _buildRadioTile(
                  title: difficulty,
                  subtitle: _getDifficultyDescription(difficulty),
                  value: difficulty,
                  groupValue: _preferences.difficulty,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(difficulty: value);
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLimitSection() {
    return _buildSection(
      title: 'Number of Questions',
      icon: Icons.format_list_numbered,
      child: Column(
        children: QuizPreferencesService.getAvailableLimits()
            .map((limit) => _buildRadioTile(
                  title: '$limit Questions',
                  subtitle: _getLimitDescription(limit),
                  value: limit,
                  groupValue: _preferences.limit,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(limit: value);
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTagsSection() {
    final availableTags = widget.category.availableTags;

    if (availableTags.isEmpty) return const SizedBox();

    return _buildSection(
      title: 'Specific Topics (Optional)',
      icon: Icons.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select specific topics you want to focus on:',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: availableTags.map((tag) {
              final isSelected = _preferences.tags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final newTags = List<String>.from(_preferences.tags);
                    if (selected) {
                      newTags.add(tag);
                    } else {
                      newTags.remove(tag);
                    }
                    _preferences = _preferences.copyWith(tags: newTags);
                  });
                },
                selectedColor:
                    Color(widget.category.color).withValues(alpha: 0.2),
                checkmarkColor: Color(widget.category.color),
              );
            }).toList(),
          ),
          if (_preferences.tags.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Selected: ${_preferences.tags.join(', ')}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color(widget.category.color),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return _buildSection(
      title: 'Quiz Options',
      icon: Icons.settings,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Single Answer Only'),
            subtitle:
                const Text('Only include questions with one correct answer'),
            value: _preferences.singleAnswerOnly,
            onChanged: (value) {
              setState(() {
                _preferences = _preferences.copyWith(singleAnswerOnly: value);
              });
            },
            activeColor: Color(widget.category.color),
          ),
        ],
      ),
    );
  }

  Widget _buildRememberPreferencesSection() {
    return _buildSection(
      title: 'Preferences',
      icon: Icons.memory,
      child: SwitchListTile(
        title: const Text('Remember My Settings'),
        subtitle: const Text('Save these preferences for future quizzes'),
        value: _preferences.rememberPreferences,
        onChanged: (value) {
          setState(() {
            _preferences = _preferences.copyWith(rememberPreferences: value);
          });
        },
        activeColor: Color(widget.category.color),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(widget.category.color), size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: Color(widget.category.color),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _startQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(widget.category.color),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Start Quiz',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _useQuickStart,
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(widget.category.color),
              side: BorderSide(color: Color(widget.category.color)),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.flash_on, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Quick Start (Default Settings)',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDifficultyDescription(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 'Basic concepts and fundamentals';
      case 'Medium':
        return 'Intermediate knowledge required';
      case 'Hard':
        return 'Advanced topics and complex scenarios';
      default:
        return '';
    }
  }

  String _getLimitDescription(int limit) {
    switch (limit) {
      case 5:
        return 'Quick 5-minute quiz';
      case 10:
        return 'Standard 10-minute quiz';
      case 15:
        return 'Extended 15-minute quiz';
      case 20:
        return 'Comprehensive 20-minute quiz';
      default:
        return 'Estimated ${limit * 1} minutes';
    }
  }

  Future<void> _startQuiz() async {
    setState(() => _isLoading = true);

    try {
      // Save preferences if user wants to remember them
      if (_preferences.rememberPreferences) {
        await QuizPreferencesService.savePreferences(_preferences);
      }

      // Navigate to quiz screen with preferences
      Get.to(
        () => EnhancedQuizScreen(
          category: widget.category,
          preferences: _preferences,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 400),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start quiz. Please try again.',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _useQuickStart() {
    // Use default preferences for quick start
    final quickPreferences = QuizPreferences(
      difficulty: widget.category.difficulty,
      limit: 10,
      tags: [],
      singleAnswerOnly: false,
      rememberPreferences: false,
    );

    Get.to(
      () => EnhancedQuizScreen(
        category: widget.category,
        preferences: quickPreferences,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 400),
    );
  }
}
