import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/views/signup/signup_screen.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'O R',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image(
              image: AssetImage('assets/google_logo.png'),
              height: 16.h,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () {},
            label: Text(
              'Sign In with Google',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Text.rich(
          TextSpan(
            text: 'Don\'t have an account? ',
            style: TextStyle(color: Colors.black, fontSize: 12.sp),
            children: [
              TextSpan(
                text: 'Sign Up',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Get.to(
                      () => const SignupScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
