import 'package:flutter/material.dart';
import 'package:wallpaper_app/views/screens/login/login_footer_widget.dart';
import 'package:wallpaper_app/views/screens/login/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(30),
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
                  'Welcome Back,',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Make it work, make it right, make it fast.',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const LoginForm(),
                const SizedBox(
                  height: 20,
                ),
                const login_footer_widget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
