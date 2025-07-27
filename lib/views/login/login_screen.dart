import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quizzler/common/constant.dart';
import 'package:quizzler/views/login/widgets/login_footer_widget.dart';
import 'package:quizzler/views/login/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                height: height * 0.3,
              ),
              Text(
                'Welcome Back!',
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
                'Make it work, make it right, make it fast.',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              const LoginForm(),
              SizedBox(
                height: 15.h,
              ),
              const LoginFooterWidget()
            ],
          ),
        ),
      ),
    );
  }
}
