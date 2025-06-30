import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';
import 'package:wallpaper_app/views/home/widgets/home_screen_header.dart';
import 'package:wallpaper_app/views/home/widgets/swipeable_quiz_stack.dart';

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
    'title': 'Quick Knowledge Test',
    'category': 'General Knowledge',
    'duration': '3min',
    'quizzes': 15,
    'sharedBy': 'Brandon Matrovs',
    'image': 'https://i.pravatar.cc/150?img=2',
    'color': const Color(0xFF4A4A4A),
  },
  {
    'title': 'Math Challenge',
    'category': 'Mathematics',
    'duration': '5min',
    'quizzes': 20,
    'sharedBy': 'Alice Johnson',
    'image': 'https://i.pravatar.cc/150?img=3',
    'color': const Color(0xFF2E7D32),
  },
  {
    'title': 'Tech Trivia',
    'category': 'Computer Science',
    'duration': '4min',
    'quizzes': 18,
    'sharedBy': 'John Doe',
    'image': 'https://i.pravatar.cc/150?img=4',
    'color': const Color(0xFF1565C0),
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
