import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';
import 'package:quizzler/views/Quiz/enhanced_quiz_screen.dart';
import 'package:quizzler/views/quiz_preferences/quiz_preferences_screen.dart';

class SuggestionDialogService {
  static const String _lastShownKey = 'last_suggestion_shown';
  static const String _dismissCountKey = 'suggestion_dismiss_count';

  // Categories with icons and colors for suggestions
  static final List<Map<String, dynamic>> _availableCategories = [
    {
      'name': 'DevOps',
      'icon': '🚀',
      'color': 0xFF2196F3,
      'description': 'Master CI/CD, Docker, and automation',
      'motivationalText': 'Level up your DevOps skills!',
      'apiCategory': 'DevOps',
    },
    {
      'name': 'Networking',
      'icon': '🌐',
      'color': 0xFFFF9800,
      'description': 'TCP/IP, routing, and protocols',
      'motivationalText': 'Connect your knowledge!',
      'apiCategory': 'Networking',
    },
    {
      'name': 'Linux',
      'icon': '🐧',
      'color': 0xFF4CAF50,
      'description': 'Commands, bash, and system admin',
      'motivationalText': 'Command your terminal skills!',
      'apiCategory': 'Linux',
    },
    {
      'name': 'Programming',
      'icon': '💻',
      'color': 0xFF9C27B0,
      'description': 'Algorithms, data structures, OOP',
      'motivationalText': 'Code your way to success!',
      'apiCategory': 'Code',
    },
    {
      'name': 'Cloud Computing',
      'icon': '☁️',
      'color': 0xFF795548,
      'description': 'AWS, Azure, serverless computing',
      'motivationalText': 'Rise to the cloud!',
      'apiCategory': 'Cloud',
    },
    {
      'name': 'Docker',
      'icon': '🐳',
      'color': 0xFFE91E63,
      'description': 'Containers, images, orchestration',
      'motivationalText': 'Containerize your knowledge!',
      'apiCategory': 'Docker',
    },
    {
      'name': 'Kubernetes',
      'icon': '⚓',
      'color': 0xFF673AB7,
      'description': 'Pods, services, deployments',
      'motivationalText': 'Orchestrate your learning!',
      'apiCategory': 'Kubernetes',
    },
  ];

  static Future<void> showSuggestionDialog(BuildContext context) async {
    if (!_shouldShowDialog()) return;

    final randomCategory = _getRandomCategory();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) =>
          _SuggestionDialog(category: randomCategory),
    );

    _updateLastShown();
  }

  static bool _shouldShowDialog() {
    // Show dialog every 3rd app open or if never shown
    final storage = GetStorage();
    final dismissCount = storage.read(_dismissCountKey) ?? 0;
    final lastShown = storage.read(_lastShownKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final hoursSinceLastShown = (now - lastShown) / (1000 * 60 * 60);

    // Show if it's been more than 4 hours since last shown or every 3rd dismiss
    return hoursSinceLastShown >= 4 || dismissCount >= 3;
  }

  static Map<String, dynamic> _getRandomCategory() {
    final random = Random();
    return _availableCategories[random.nextInt(_availableCategories.length)];
  }

  static void _updateLastShown() {
    final storage = GetStorage();
    storage.write(_lastShownKey, DateTime.now().millisecondsSinceEpoch);
    storage.write(_dismissCountKey, 0); // Reset dismiss count
  }

  static void _incrementDismissCount() {
    final storage = GetStorage();
    final currentCount = storage.read(_dismissCountKey) ?? 0;
    storage.write(_dismissCountKey, currentCount + 1);
  }
}

class _SuggestionDialog extends StatefulWidget {
  final Map<String, dynamic> category;

  const _SuggestionDialog({required this.category});

  @override
  State<_SuggestionDialog> createState() => _SuggestionDialogState();
}

class _SuggestionDialogState extends State<_SuggestionDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
    _pulseController.repeat();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(20.w),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(widget.category['color']),
                      Color(widget.category['color']).withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(widget.category['color'])
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BackgroundPatternPainter(),
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Close button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  SuggestionDialogService
                                      ._incrementDismissCount();
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          // Category icon with pulse animation
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 80.w,
                                  height: 80.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(40.r),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.category['icon'],
                                      style: TextStyle(fontSize: 40.sp),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 20.h),

                          // Motivational text
                          Text(
                            widget.category['motivationalText'],
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 8.h),

                          // Category name
                          Text(
                            'Let\'s revise ${widget.category['name']}',
                            style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 12.h),

                          // Description
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              widget.category['description'],
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _startQuickQuiz();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor:
                                        Color(widget.category['color']),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.flash_on, size: 18.sp),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Quick Quiz',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _customizeQuiz();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Colors.white, width: 1.5),
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.tune, size: 18.sp),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Customize',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),

                          // Maybe later button
                          TextButton(
                            onPressed: () {
                              SuggestionDialogService._incrementDismissCount();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Maybe later',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _startQuickQuiz() {
    final category = QuizCategory(
      id: widget.category['name'].toLowerCase().replaceAll(' ', '_'),
      name: widget.category['name'],
      iconPath: 'assets/computer-science.png',
      color: widget.category['color'],
      difficulty: 'Medium',
      quizCount: 0,
      isActive: true,
      availableTags: [],
      apiCategory: widget.category['apiCategory'],
    );

    const preferences = QuizPreferences(
      difficulty: 'Medium',
      limit: 10,
      singleAnswerOnly: false,
    );

    Get.to(
      () => EnhancedQuizScreen(
        category: category,
        preferences: preferences,
      ),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _customizeQuiz() {
    final category = QuizCategory(
      id: widget.category['name'].toLowerCase().replaceAll(' ', '_'),
      name: widget.category['name'],
      iconPath: 'assets/computer-science.png',
      color: widget.category['color'],
      difficulty: 'Medium',
      quizCount: 0,
      isActive: true,
      availableTags: [],
      apiCategory: widget.category['apiCategory'],
    );

    Get.to(
      () => QuizPreferencesScreen(category: category),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 400),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        final x = (size.width / 5) * i;
        final y = (size.height / 5) * j;
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
