import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/screens/signup/sign_bottom.dart';
import 'package:wallpaper_app/views/screens/signup/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Image(
                  image: const AssetImage(
                    'assets/image1.png',
                  ),
                  height: size.height * 0.2,
                ),
                const Text(
                  'Get On Board!',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Create your profile to start your Journey.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SignUpForm(),
                const SizedBox(
                  height: 20,
                ),
                const SignupBottom()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
