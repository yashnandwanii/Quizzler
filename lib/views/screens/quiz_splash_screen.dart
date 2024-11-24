import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:wallpaper_app/views/screens/login/login_screen.dart';
import 'package:wallpaper_app/views/screens/signup/signup_screen.dart';

class QuizSplashScreen extends StatelessWidget {
  const QuizSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black12,
              Colors.black87,
            ],
          ),
        ),
        // ignore: prefer_const_constructors
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Image(
              image: AssetImage('assets/image1.png'),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              'Welcome to the quiz app...',
              style: TextStyle(color: Colors.grey[200], fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Quiz Night',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 130,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.blue,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          PageTransition(
                            child: const SignupScreen(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      child: const Text(
                        'SIGNUP',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        iconColor: Colors.blue,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          PageTransition(
                            child: const LoginScreen(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      )),
                ),
              ],
            )
          ],
        )),
      ),
    );
  }
}
