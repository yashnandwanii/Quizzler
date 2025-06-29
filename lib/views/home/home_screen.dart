import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';
import 'package:wallpaper_app/views/home/widgets/home_screen_header.dart';
import 'package:wallpaper_app/views/home/widgets/quizzes_section.dart';
import 'package:wallpaper_app/views/home/widgets/swipeable_quiz_stack.dart';
import 'package:wallpaper_app/model/quiz_history_model.dart' as quiz_history;
import 'package:wallpaper_app/model/quiz_model.dart' as quiz_model;
import 'package:wallpaper_app/views/GivenQuizzes/givenquizzes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

final List<QuizCategory> yourQuizzes = [
  QuizCategory(
      name: 'Integers Quiz', iconPath: 'assets/maths.png', quizCount: 10),
  QuizCategory(
      name: 'General Knowledge', iconPath: 'assets/school.png', quizCount: 6),
  QuizCategory(
      name: 'Computer Science',
      iconPath: 'assets/computer-science.png',
      quizCount: 12),
];

final List<Map<String, dynamic>> quizCards = [
  {
    'title': 'Saturday night Quiz',
    'category': 'General Knowledge',
    'duration': '2min',
    'quizzes': 13,
    'sharedBy': 'Brandon Matrovs',
    'image': 'https://i.pravatar.cc/150?img=2',
    'color': const Color(0xFF4A4A4A),
  },
  {
    'title': 'Math Mastery',
    'category': 'Mathematics',
    'duration': '5min',
    'quizzes': 8,
    'sharedBy': 'Alice Johnson',
    'image': 'https://i.pravatar.cc/150?img=3',
    'color': const Color(0xFF2E7D32),
  },
  {
    'title': 'Tech Trivia',
    'category': 'Computer Science',
    'duration': '3min',
    'quizzes': 10,
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
    _fetchRecentQuizzes();
  }

  Future<void> _fetchRecentQuizzes() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;
    if (userId == null) return;

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .orderBy('date', descending: true)
          .limit(3)
          .get();

      final List<Map<String, dynamic>> quizzesWithMeta = [];

      for (final doc in query.docs) {
        final data = doc.data();
        final quizId = data['quizId'];
        if (quizId == null) continue; // skip if missing

        final metaDoc = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quizId)
            .get();

        if (metaDoc.exists && metaDoc.data() != null) {
          final metaDataMap = metaDoc.data()!.containsKey('metadata')
              ? metaDoc['metadata']
              : metaDoc.data(); // fallback if stored directly

          quizzesWithMeta.add({
            'meta': quiz_model.QuizMetaModel.fromMap(metaDataMap),
            'history': quiz_history.QuizHistory.fromMap(data),
          });
        }
      }

      setState(() {
        recentQuizzes = quizzesWithMeta;
      });
    } catch (e) {
      debugPrint('Error fetching recent quizzes: $e');
    }
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
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      SwipeableQuizStack(quizCards: quizCards),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            'Your Quizzes',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => const Givenquizzes(),
                                transition: Transition.rightToLeft,
                                duration: const Duration(milliseconds: 500),
                              );
                            },
                            child: Text(
                              'See all',
                              style: GoogleFonts.robotoMono(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      _buildYourQuizzesSection(),
                      SizedBox(height: 10.h),
                      QuizzesSection(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildYourQuizzesSection() {
    if (recentQuizzes.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.quiz, size: 48, color: Colors.grey.shade300),
            SizedBox(height: 8.h),
            Text('No quizzes played yet!',
                style: TextStyle(color: Colors.grey.shade600)),
            SizedBox(height: 4.h),
            Text('Start a quiz to see it here.',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentQuizzes.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final quiz = recentQuizzes[index];
        final meta = quiz['meta'];
        final history = quiz['history'];
        return ListTile(
          leading: meta.imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(meta.imageUrl,
                      width: 48, height: 48, fit: BoxFit.cover),
                )
              : Icon(Icons.quiz, size: 36, color: Colors.blue),
          title: Text(meta.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meta.category,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              Text('Score: ${history.score}',
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
              Text(
                  'Completed: ${history.date.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios,
              size: 16, color: Colors.grey.shade400),
          onTap: () {},
        );
      },
    );
  }
}
