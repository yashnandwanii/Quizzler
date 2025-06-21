import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/GivenQuizzes/givenquizzes.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';
import 'package:wallpaper_app/views/Category/categories_screen.dart';

// --- Models ---
class QuizCategory {
  final String name;
  final String iconPath; // Using local asset paths for icons
  final int quizCount;

  QuizCategory({
    required this.name,
    required this.iconPath,
    required this.quizCount,
  });
}

// --- Data ---
// In a real app, this would come from a database.
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

// --- UI ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String wish = 'Good Morning';

  List<Map<String, dynamic>> quizCards = [
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
                      _buildHeader(user),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            'Quizzes',
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
                                () => CategoriesScreen(),
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
                      Container(
                        height: 200.h,
                        margin: EdgeInsets.symmetric(horizontal: 5.w),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: quizCards
                              .asMap()
                              .entries
                              .map((entry) {
                                int index = entry.key;
                                final card = entry.value;

                                if (index > 2) return const SizedBox();

                                double topOffset = 10.0 * index;
                                double scale = 1.0 - (0.05 * index);

                                return Positioned(
                                  top: topOffset.h,
                                  child: AnimatedScale(
                                    scale: scale,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    child: index == 0
                                        ? Dismissible(
                                            key: Key(card['title']),
                                            direction:
                                                DismissDirection.horizontal,
                                            onDismissed: (direction) {
                                              setState(() {
                                                final removed =
                                                    quizCards.removeAt(0);
                                                quizCards.add(removed);
                                              });
                                            },
                                            child: _buildMainQuizCard(
                                              title: card['title'],
                                              category: card['category'],
                                              duration: card['duration'],
                                              quizzes: card['quizzes'],
                                              sharedBy: card['sharedBy'],
                                              avatarUrl: card['image'],
                                              backgroundColor: card['color'],
                                            ),
                                          )
                                        : _buildMainQuizCard(
                                            title: card['title'],
                                            category: card['category'],
                                            duration: card['duration'],
                                            quizzes: card['quizzes'],
                                            sharedBy: card['sharedBy'],
                                            avatarUrl: card['image'],
                                            backgroundColor: card['color'],
                                          ),
                                  ),
                                );
                              })
                              .toList()
                              .reversed
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildYourQuizzesSection(),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wish.toUpperCase(),
              style: GoogleFonts.robotoMono(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            SizedBox(height: 4.h),
            Text(
              user.fullName.split(' ').first, // Show first name
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 20.r,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : const AssetImage('assets/app_logo.png') as ImageProvider,
        ),
      ],
    );
  }

  Widget _buildMainQuizCard({
    String? title,
    String? category,
    String? duration,
    int? quizzes,
    String? sharedBy,
    String? avatarUrl,
    Color? backgroundColor,
  }) {
    return Container(
      height: 180.h,
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(category ?? 'General Knowledge',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(duration ?? '2min',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Spacer(),
              const Icon(Icons.close, color: Colors.white),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            title ?? 'Saturday night Quiz',
            style: GoogleFonts.inter(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text('${quizzes ?? 13} Quizzes',
              style: TextStyle(color: Colors.white70)),
          SizedBox(height: 10.h),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 8.w),
              Text(
                'Shared By\n${sharedBy ?? 'Brandon Matrovs'}',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 30, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                ),
                child: Text(
                  'Start Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYourQuizzesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your Quizzes',
                style: GoogleFonts.inter(
                    fontSize: 20.sp, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Get.to(
                  () => Givenquizzes(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300),
                  fullscreenDialog: true,
                  popGesture: true,
                );
              },
              child: Text(
                'See all',
                style: GoogleFonts.robotoMono(
                    fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: yourQuizzes.length,
          itemBuilder: (context, index) {
            final category = yourQuizzes[index];
            return _buildQuizListItem(category);
          },
        ),
      ],
    );
  }

  Widget _buildQuizListItem(QuizCategory category) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Image.asset(category.iconPath, width: 30.w),
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text('${category.quizCount} Quizzes',
                        style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart, color: Color(0xFF3D5CFF)),
                  label: const Text(
                    'Results',
                    style: TextStyle(color: Color.fromARGB(255, 37, 72, 243)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Stack(
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(left: (18 * index).toDouble()),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=${index + 4}'),
                    ),
                  );
                }),
              ),
              SizedBox(width: (18 * 3).w + 8.w),
              Text(
                '+437 People join',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
