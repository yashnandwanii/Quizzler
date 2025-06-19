// ignore_for_file: library_private_types_in_public_api

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/home/home_screen.dart';
import 'package:wallpaper_app/views/screens/categories_screen.dart';
import 'package:wallpaper_app/views/screens/profile_page.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int currentIndex = 0;

  // Screens for bottom navigation
  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
