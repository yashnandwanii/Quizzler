import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/services/suggestion_dialog_service.dart';
import 'package:quizzler/views/home/widgets/home_screen_header.dart';
import 'package:quizzler/views/home/widgets/swipeable_quiz_stack.dart';
import 'package:quizzler/repository/user_repository/user_repository.dart';
import 'package:quizzler/model/user_model.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/views/widgets/custom_quiz_input_card.dart';

class QuizCategory {
  final String name;
  final String iconPath;
  final int quizCount;

  QuizCategory({
    required this.name,
    required this.iconPath,
    required this.quizCount,
  });
}

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

class _HomeScreenState extends State<HomeScreen> {
  String wish = 'Good Morning';
  List<Map<String, dynamic>> recentQuizzes = [];

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

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final userRepo = Get.find<UserRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: FutureBuilder<UserModel?>(
            future: userRepo.getUserData(userId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text("Could not load user data."));
              }
              final user = snapshot.data!;
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
                      SizedBox(height: 20.h),

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
