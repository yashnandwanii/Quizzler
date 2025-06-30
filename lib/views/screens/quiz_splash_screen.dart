import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/views/login/login_screen.dart';
import 'package:wallpaper_app/views/signup/signup_screen.dart';

class QuizSplashScreen extends StatelessWidget {
  const QuizSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('QuizSplashScreen built');
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent.shade100,
              Color.fromARGB(255, 22, 91, 88),
              Color.fromARGB(199, 22, 91, 88),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10.w,
              vertical: 15.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Image(
                  image: AssetImage('assets/image1.png'),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Text(
                  'Welcome to ',
                  style: GoogleFonts.robotoMono(
                    color: Colors.grey[200],
                    fontSize: 13.h,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Text(
                  'Quizzler',
                  style: GoogleFonts.robotoMono(
                    color: Colors.blue.shade300,
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 100.h,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          Get.to(
                            () => const SignupScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: Text(
                          'S I G N  U P',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.h,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 12.h,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 1.w),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: () {
                          Get.to(
                            () => const LoginScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                          );
                        },
                        child: Text(
                          'L O G I N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
