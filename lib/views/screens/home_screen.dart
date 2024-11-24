import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/services/quote_api.dart';
import 'package:wallpaper_app/views/screens/categories_screen.dart';
import 'package:wallpaper_app/views/screens/profile_page.dart';
import 'package:wallpaper_app/views/screens/quiz_screen.dart';

class NewhomeScreen extends StatefulWidget {
  const NewhomeScreen({super.key});

  @override
  _NewhomeScreenState createState() => _NewhomeScreenState();
}

class _NewhomeScreenState extends State<NewhomeScreen> {
  int currentIndex = 0;

  // Screens for bottom navigation
  final List<Widget> _screens = [
    const HomeContent(),
    const CategoriesScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[currentIndex], // Dynamically load content based on index
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: Colors.white,
        height: 70,
        color: const Color.fromRGBO(42, 43, 48, 1),
        onTap: (selectedIndex) {
          setState(() {
            currentIndex = selectedIndex;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.category, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}

// Home Content Widget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    const String username = 'Rahul'; // Can fetch dynamically if needed
    final Future<String> data = QuoteApi.getQuote();

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
                    Text(
                      'Welcome, $username',
                      style: GoogleFonts.arvo(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      icon: IconButton(
                        onPressed: () {
                          AuthenticationRepository.instance.logout();
                        },
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
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
                margin: const EdgeInsets.only(top: 150, left: 20, right: 20),
                color: const Color.fromRGBO(42, 43, 48, 1),
                child: Center(
                  child: FutureBuilder<String>(
                    future: data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(
                          color: Colors.white,
                        );
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
          // Categories Grid
          SizedBox(
            height: 300,
            width: double.infinity,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
              ),
              children: [
                _buildCategoryTile(
                  'General Knowledge',
                  'assets/school.png',
                  QuizScreen(category: 9, any: false),
                  context,
                ),
                _buildCategoryTile(
                  'Computer Science',
                  'assets/computer-science.png',
                  QuizScreen(category: 18, any: false),
                  context,
                ),
                _buildCategoryTile(
                  'Sports',
                  'assets/sports.png',
                  QuizScreen(category: 21, any: false),
                  context,
                ),
                _buildCategoryTile(
                  'Mathematics',
                  'assets/maths.png',
                  QuizScreen(category: 19, any: false),
                  context,
                ),
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
  }

  // Helper function to build category tiles
  Widget _buildCategoryTile(
      String title, String imagePath, Widget screen, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: SizedBox(
        height: 300,
        width: 100,
        child: Column(
          children: [
            Image(image: AssetImage(imagePath), width: 70),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
