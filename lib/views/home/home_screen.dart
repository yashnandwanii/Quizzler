// Home Content Widget
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/services/quote_api.dart';
import 'package:wallpaper_app/views/home/widgets/category_tile.dart';
import 'package:wallpaper_app/views/screens/categories_screen.dart';
import 'package:wallpaper_app/views/screens/profile_page.dart';
import 'package:wallpaper_app/views/screens/quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final box = GetStorage();
  UserModel? user;
  final AuthenticationRepository _authRepo =
      Get.put(AuthenticationRepository());
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = box.read('user');

    if (userData == null) {
      Get.snackbar('Error', 'User data not found');
      user = UserModel(id: '', fullName: 'Guest', email: '', password: '');
    } else {
      user = UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<String> data = QuoteApi.getQuote();

    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 55, left: 20),
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(42, 43, 48, 1),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                            'https://imgs.search.brave.com/Mpac-KOW2uEx8_Ot8ajvzF8kaqCCZRVozZ-SkZnfujQ/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzA2Lzc1Lzc4Lzk5/LzM2MF9GXzY3NTc4/OTk0M18yMDR3dFh2/YlMxa0JUd2JDNGhO/N2tVSGNtRGN0OVIw/di5qcGc',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Welcome, ${user!.fullName}',
                            style: GoogleFonts.arvo(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ProfilePage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_outlined,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 100, left: 20),
                    child: Text(
                      'Fact of the Day:',
                      style: GoogleFonts.trocchi(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Card(
                    elevation: 0.0,
                    margin:
                        const EdgeInsets.only(top: 150, left: 20, right: 20),
                    color: const Color.fromRGBO(42, 43, 48, 1),
                    child: Center(
                      child: FutureBuilder<String>(
                        future: data,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(
                                color: Colors.white);
                          } else if (snapshot.hasError) {
                            return const Text(
                              'Error loading quote!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text(
                              snapshot.data ?? 'No quote available',
                              style: GoogleFonts.trocchi(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Top Quiz Categories
              Row(
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'Top Quiz Categories',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),

              SizedBox(
                height: 300,
                width: double.infinity,
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2,
                  ),
                  children: [
                    CategoryTile(
                      title: 'General Knowledge',
                      imagePath: 'assets/school.png',
                      screen: QuizScreen(category: 9, any: false),
                      context: context,
                    ),
                    CategoryTile(
                        title: 'Computer Science',
                        imagePath: 'assets/computer-science.png',
                        screen: QuizScreen(category: 18, any: false),
                        context: context),
                    CategoryTile(
                        title: 'Sports',
                        imagePath: 'assets/sports.png',
                        screen: QuizScreen(category: 21, any: false),
                        context: context),
                    CategoryTile(
                        title: 'Mathematics',
                        imagePath: 'assets/maths.png',
                        screen: QuizScreen(category: 19, any: false),
                        context: context),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Daily Quiz Card
              Card(
                elevation: 4,
                surfaceTintColor: Colors.white38,
                child: SizedBox(
                  width: double.infinity,
                  height: 150,
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      const Text(
                        'Daily Quiz',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuizScreen(category: 10, any: true),
                            ),
                          );
                        },
                        child: const Text(
                          'Play Now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
