// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:quizzler/views/Profile/profile_page.dart';
import 'package:quizzler/views/categories/categories_screen.dart';
import 'package:quizzler/views/home/home_screen.dart';
import 'package:quizzler/views/leaderboard/enhanced_leaderboard_screen.dart';
import 'package:quizzler/views/quiz_history/quiz_history_screen.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int currentIndex = 0;

  // Use late initialization to create screens only once and keep them in memory
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize screens once and keep them in memory
    _screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const EnhancedLeaderboardScreen(),
      const QuizHistoryScreen(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Use IndexedStack to keep all screens in memory and preserve their state
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: Colors.white,
        height: 70,
        color: Colors.blue.shade900,
        buttonBackgroundColor: const Color.fromARGB(255, 33, 54, 243),
        onTap: (selectedIndex) {
          setState(() {
            currentIndex = selectedIndex;
          });
        },
        animationDuration: const Duration(milliseconds: 400),
        items: const [
          Icon(Icons.home_outlined, size: 30, color: Colors.white),
          Icon(Icons.quiz_outlined, size: 30, color: Colors.white),
          Icon(Icons.leaderboard_outlined, size: 30, color: Colors.white),
          Icon(Icons.history_outlined, size: 30, color: Colors.white),
          Icon(Icons.person_outline, size: 30, color: Colors.white),
        ],
      ),
    );
  }
}
