import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/views/login/login_screen.dart';

class SignupBottom extends StatelessWidget {
  const SignupBottom({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final AuthenticationRepository authRepo = AuthenticationRepository.instance;
    return Column(
      children: [
        Text(
          'O R',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(
          height: 15.h,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Image(
              image: const AssetImage('assets/google_logo.png'),
              height: 16.h,
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () async {
              final userCredentials = await authRepo.signInWithGoogle();
              if (userCredentials != null) {
                debugPrint('User signed in: ${userCredentials.user}');
              } else {
                debugPrint('Google Sign-In failed');
              }
            },
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
            text: 'Already have an account? ',
            style: TextStyle(color: Colors.black, fontSize: 12.sp),
            children: [
              TextSpan(
                text: 'LOGIN',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Navigate to Login Screen

                    Get.to(
                      () => const LoginScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
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
