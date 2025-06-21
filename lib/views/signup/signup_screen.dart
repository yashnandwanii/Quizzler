import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wallpaper_app/common/constant.dart';
import 'package:wallpaper_app/views/signup/widgets/signup_bottom.dart';
import 'package:wallpaper_app/views/signup/widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offwhite,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
            top: 50.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 10.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                image: const AssetImage(
                  'assets/image1.png',
                ),
                height: height * 0.35,
              ),
              Text(
                'Get On Board!',
                style: GoogleFonts.robotoMono(
                  color: Colors.black,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'Create your profile to start your Journey.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              const SignUpForm(),
              SizedBox(
                height: 15.h,
              ),
              const SignupBottom()
            ],
          ),
        ),
      ),
    );
  }
}
