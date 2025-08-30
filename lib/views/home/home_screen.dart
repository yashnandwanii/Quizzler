import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizzler/services/suggestion_dialog_service.dart';
import 'package:quizzler/services/gemini_ai_service.dart';
import 'package:quizzler/model/quiz_preferences_model.dart';
import 'package:quizzler/views/home/widgets/home_screen_header.dart';
import 'package:quizzler/views/home/widgets/swipeable_quiz_stack.dart';
import 'package:quizzler/views/Quiz/enhanced_quiz_screen.dart';
import 'package:quizzler/repository/user_repository/user_repository.dart';
import 'package:quizzler/model/user_model.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/views/widgets/custom_quiz_input_card.dart';
import 'package:quizzler/views/revision/revision_mode_screen.dart';

final List<Map<String, dynamic>> quizCards = [
  {
    'title': 'Linux Bonanza',
    'category': 'Linux',
    'duration': '5min',
    'quizzes': 20,
    'sharedBy': 'Terminal Master',
    'image': 'https://i.pravatar.cc/150?img=2',
    'color': const Color(0xFFF39C12),
  },
  {
    'title': 'DevOps Mastery',
    'category': 'DevOps',
    'duration': '6min',
    'quizzes': 15,
    'sharedBy': 'Pipeline Pro',
    'image': 'https://i.pravatar.cc/150?img=3',
    'color': const Color(0xFFE74C3C),
  },
  {
    'title': 'Network Ninja',
    'category': 'Networking',
    'duration': '4min',
    'quizzes': 18,
    'sharedBy': 'Router Rick',
    'image': 'https://i.pravatar.cc/150?img=4',
    'color': const Color(0xFF3498DB),
  },
  {
    'title': 'Code Crusade',
    'category': 'Code',
    'duration': '7min',
    'quizzes': 25,
    'sharedBy': 'Bug Hunter',
    'image': 'https://i.pravatar.cc/150?img=5',
    'color': const Color(0xFF9B59B6),
  },
  {
    'title': 'Cloud Commander',
    'category': 'Cloud',
    'duration': '5min',
    'quizzes': 20,
    'sharedBy': 'Sky Walker',
    'image': 'https://i.pravatar.cc/150?img=6',
    'color': const Color(0xFF1ABC9C),
  },
  {
    'title': 'Docker Dynamo',
    'category': 'Docker',
    'duration': '4min',
    'quizzes': 16,
    'sharedBy': 'Container King',
    'image': 'https://i.pravatar.cc/150?img=7',
    'color': const Color(0xFF2980B9),
  },
  {
    'title': 'Kubernetes Quest',
    'category': 'Kubernetes',
    'duration': '8min',
    'quizzes': 30,
    'sharedBy': 'Pod Master',
    'image': 'https://i.pravatar.cc/150?img=8',
    'color': const Color(0xFF8E44AD),
  },
  {
    'title': 'Quick Brain Burst',
    'category': 'General',
    'duration': '3min',
    'quizzes': 12,
    'sharedBy': 'Quiz Genius',
    'image': 'https://i.pravatar.cc/150?img=9',
    'color': const Color(0xFF34495E),
  },
  {
    'title': 'Random Knowledge',
    'category': 'Random',
    'duration': '6min',
    'quizzes': 22,
    'sharedBy': 'Trivia Titan',
    'image': 'https://i.pravatar.cc/150?img=10',
    'color': const Color(0xFF16A085),
  },
  {
    'title': 'Tech Titans',
    'category': 'Linux',
    'duration': '5min',
    'quizzes': 18,
    'sharedBy': 'Open Source',
    'image': 'https://i.pravatar.cc/150?img=11',
    'color': const Color(0xFFD35400),
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String wish = 'Good Morning';
  List<Map<String, dynamic>> recentQuizzes = [];

  @override
  bool get wantKeepAlive => true; // This keeps the state alive

  @override
  void initState() {
    super.initState();
    getWish();
    // Show suggestion dialog after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SuggestionDialogService.showSuggestionDialog(context);
    });
  }

  void getWish() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      wish = 'Good Morning';
    } else if (hour < 18) {
      wish = 'Good Afternoon';
    } else {
      wish = 'Good Evening';
    }
  }

  Future<List<Map<String, dynamic>>> _fetchWrongAttempts() async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;
      if (userId == null) return [];

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("Wrong_attempts")
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['docId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching wrong attempts: $e');
      return [];
    }
  }

  void _showRevisionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final wrongAttempts = await _fetchWrongAttempts();
    Navigator.pop(context); // Close loading dialog

    if (wrongAttempts.isEmpty) {
      Get.snackbar(
        'No Revision Available',
        'You haven\'t made any mistakes yet! Take some quizzes first.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
      return;
    }

    // Show action dialog with only buttons
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        contentPadding: EdgeInsets.all(24.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Smart Revision',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '${wrongAttempts.length} questions available for review',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Get.to(() =>
                          RevisionModeScreen(wrongAttempts: wrongAttempts));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Revise',
                          style: GoogleFonts.inter(
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _startAiRevisionQuiz();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      side:
                          const BorderSide(color: Color(0xFF6C63FF), width: 2),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.quiz_outlined, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Quiz',
                          style: GoogleFonts.inter(
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startAiRevisionQuiz() async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final user = authRepo.firebaseUser.value;
      if (user == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF6C63FF),
                strokeWidth: 3.w,
              ),
              SizedBox(height: 16.h),
              Text(
                'AI is rephrasing your questions...',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'This may take a moment',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Get wrong attempts from Firestore
      final wrongAttemptsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('Wrong_attempts')
          .get();

      print('Wrong attempts found: ${wrongAttemptsSnapshot.docs.length}');

      if (wrongAttemptsSnapshot.docs.isEmpty) {
        Navigator.pop(context);
        Get.snackbar('No Data', 'No wrong attempts found for revision');
        return;
      }

      final allWrongAttempts = <Map<String, dynamic>>[];

      // Collect all wrong attempts from all documents in the subcollection
      for (final doc in wrongAttemptsSnapshot.docs) {
        final data = doc.data();
        // Each document represents a wrong attempt
        allWrongAttempts.add(data);
      }

      if (allWrongAttempts.isEmpty) {
        Navigator.pop(context);
        Get.snackbar('No Data', 'No wrong attempts found for revision');
        return;
      }

      // Initialize Gemini AI service
      if (!Get.isRegistered<GeminiAIService>()) {
        Get.put(GeminiAIService());
      }
      final geminiService = Get.find<GeminiAIService>();

      // Prepare topic and requirements for AI
      final topics = allWrongAttempts
          .map((attempt) => attempt['category'] ?? 'General')
          .toSet()
          .join(', ');
      final specificRequirements = '''
You are given a list of quiz questions that the user answered incorrectly. 
Your task is to create new quiz questions that assess the same concepts but 
in a fresh way. Use the details below for reference:

${allWrongAttempts.map((attempt) => '''
Original Question: ${attempt['question'] ?? 'No question'}
Original Options: ${(attempt['options'] as List<dynamic>?)?.join(', ') ?? 'No options'}
Correct Answer: ${attempt['correctAnswer'] ?? 'No correct answer'}
User's Wrong Answer: ${attempt['userAnswer'] ?? 'No user answer'}
Explanation: ${attempt['explanation'] ?? 'No explanation'}
''').join('\n\n')}

### Instructions for the new questions:
1. Rephrase the original questions with different wording, while keeping the same learning objective.  
2. Ensure the difficulty level remains the same.  
3. Provide **four answer options**, with exactly one correct answer.  
4. Clearly mark the correct answer.  
5. Add a short **explanation** that clarifies why the correct answer is correct.  
6. Present the output in strict JSON format as shown below:

{
  "questions": [
    {
      "question": "string",
      "options": ["string", "string", "string", "string"],
      "correctAnswer": "string",
      "explanation": "string"
    }
  ]
}
''';

      final aiQuizzes = await geminiService.generateCustomQuiz(
        topic: topics.isNotEmpty ? topics : 'Mixed Topics Revision',
        difficulty: 'Mixed',
        numberOfQuestions: allWrongAttempts.length.clamp(1, 10),
        specificRequirements: specificRequirements,
      );

      // Close loading dialog
      Navigator.pop(context);

      if (aiQuizzes.isEmpty) {
        Get.snackbar('Error', 'No valid questions generated');
        return;
      }

      // Create quiz category for AI revision
      final quizCategory = QuizCategory(
        id: 'ai_revision_${DateTime.now().millisecondsSinceEpoch}',
        name: 'AI Revision Quiz',
        iconPath: 'assets/icons/refresh.png',
        color: 0xFF6C63FF,
        difficulty: 'Mixed',
        quizCount: aiQuizzes.length,
        isActive: true,
        availableTags: ['revision', 'ai-rephrased'],
        apiCategory: 'AI_Revision',
      );

      final quizPreferences = QuizPreferences(
        difficulty: 'Mixed',
        limit: aiQuizzes.length,
        tags: ['revision'],
      );

      // Navigate to Enhanced Quiz Screen
      Get.to(() => EnhancedQuizScreen(
            category: quizCategory,
            preferences: quizPreferences,
            preGeneratedQuestions: aiQuizzes,
          ));

      Get.snackbar(
        'AI Revision Quiz Started! 🤖',
        'Successfully created ${aiQuizzes.length} rephrased questions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.w),
        borderRadius: 12.r,
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      Get.snackbar('Error', 'Failed to start AI revision quiz: $e');
      print('AI Revision Quiz Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final authRepo = Get.find<AuthenticationRepository>();
    final userRepo = Get.find<UserRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to continue.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
            future: userRepo.getUserData(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Handle error or missing data by creating a default user
              UserModel user;
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null) {
                debugPrint(
                    'User data not found or error occurred. Creating default user.');
                // Create a default user with Firebase user info
                final firebaseUser = authRepo.firebaseUser.value;
                user = UserModel(
                  id: userId,
                  fullName: firebaseUser?.displayName ?? 'User',
                  email: firebaseUser?.email ?? 'user@example.com',
                  password: '', // Not needed for display
                  photoUrl: firebaseUser?.photoURL ?? '',
                  coins: 0,
                  rank: 0,
                );

                // Try to create the user document in Firestore in the background
                Future.microtask(() async {
                  try {
                    await userRepo.createUser(user);
                    debugPrint('Created missing user document for $userId');
                  } catch (e) {
                    debugPrint('Failed to create user document: $e');
                  }
                });
              } else {
                user = snapshot.data!;
              }
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      HomeScreenHeader(wish: wish, user: user),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            'Personalized Quizzes',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // AI Quiz Generator Card
                      const CustomQuizInputCard(),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            'Featured Quizzes',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SwipeableQuizStack(quizCards: quizCards),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Text(
                            'Revision Quizzes',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // Smart AI Reviser Card
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromARGB(255, 14, 198, 85),
                              Color.fromARGB(255, 10, 166, 180),
                              Color.fromARGB(255, 216, 94, 6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.psychology_outlined,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Smart AI Reviser',
                                        style: GoogleFonts.inter(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Turn mistakes into mastery',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'AI',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              "Strengthen your concepts from your previous mistakes",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            InkWell(
                              onTap: _showRevisionDialog,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.h),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Start Revision',
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Container(
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
