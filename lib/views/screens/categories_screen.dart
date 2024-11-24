import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/screens/quiz_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  Widget CategoryCard(
      {required String title,
      required String imageUrl,
      required int categoryId}) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      child: Column(
        children: [
          Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            height: 100,
          ),
          Text(title),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
        ),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 9, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 9,
              title: 'General Knowledge',
              imageUrl: 'assets/school.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 9, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 18,
              title: 'Computers Science',
              imageUrl: 'assets/computer-science.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 19, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 19,
              title: 'Mathematics',
              imageUrl: 'assets/maths.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 30, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 30,
              title: 'Gadgets',
              imageUrl: 'assets/gadgets.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 23, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 23,
              title: 'History',
              imageUrl: 'assets/history.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 24, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 24,
              title: 'Politics',
              imageUrl: 'assets/politics.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 17, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 17,
              title: 'Animals',
              imageUrl: 'assets/animals.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 22, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 22,
              title: 'Sports',
              imageUrl: 'assets/sports.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 27, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 27,
              title: 'Mythology',
              imageUrl: 'assets/mythology.png',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return QuizScreen(category: 28, any: false);
              }));
            },
            child: CategoryCard(
              categoryId: 12,
              title: 'Music',
              imageUrl: 'assets/music.png',
            ),
          ),
        ],
      ),
    );
  }
}
