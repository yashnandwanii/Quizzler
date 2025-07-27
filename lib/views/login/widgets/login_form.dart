import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/views/home/main_tab_view.dart';
import 'package:quizzler/views/signup/widgets/password_field.dart';
import 'package:quizzler/views/widgets/rount_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool isPasswordHidden = true.obs;
  final AuthenticationRepository _authRepo =
      Get.find<AuthenticationRepository>();

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your email';
              }
              // Simple email validation
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            hintText: 'Enter your email',
            labelText: 'Email',
            icon: Icons.email_outlined,
            controller: _emailController,
          ),
          SizedBox(
            height: 10.h,
          ),
          PasswordField(
            controller: _passwordController,
            hintText: 'Enter you password',
            labelText: 'Password',
            isObscure: isPasswordHidden,
            icon: Icons.lock_outline,
          ),
          SizedBox(
            height: 10.h,
          ),
          // Align(
          //   alignment: Alignment.centerRight,
          //   child: TextButton(
          //     onPressed: () {
          //       showModalBottomSheet(
          //         shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(20)),
          //         context: context,
          //         builder: (context) {
          //           var children = [
          //             const Text(
          //               'Make Selection!',
          //               style: TextStyle(
          //                 fontSize: 20,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             const SizedBox(
          //               height: 20,
          //             ),
          //             const Text(
          //               'Select one of the options given below to reset your password.',
          //               style: TextStyle(
          //                 fontSize: 16,
          //               ),
          //             ),
          //             const SizedBox(
          //               height: 20,
          //             ),
          //             ForgetPasswordbtnWidget(
          //               icon: Icons.email_outlined,
          //               title: 'Email',
          //               subtitle: 'Reset password via email',
          //               onClick: () {
          //                 Navigator.pop(context);
          //                 Navigator.push(
          //                   context,
          //                   MaterialPageRoute(
          //                     builder: (context) =>
          //                         const ForgotPasswordMailScreen(),
          //                   ),
          //                 );
          //               },
          //             ),
          //             const SizedBox(
          //               height: 20,
          //             ),
          //             ForgetPasswordbtnWidget(
          //               icon: Icons.phone_outlined,
          //               title: 'Phone',
          //               subtitle: 'Reset password via phone',
          //               onClick: () {},
          //             ),
          //           ];
          //           return Container(
          //             padding: const EdgeInsets.all(30.0),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: children,
          //             ),
          //           );
          //         },
          //       );
          //     },
          //     child: const Text(
          //       'Forgot Password?',
          //       style: TextStyle(color: Colors.blue),
          //     ),
          //   ),
          // ),
          // Obx(

          Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () async {
                  // Implement login functionality here
                  if (EmailValidator.validate(_emailController.text) &&
                      _passwordController.text.isNotEmpty) {
                    if (formKey.currentState!.validate()) {
                      // Navigate to Home Screen

                      final user = await _authRepo.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );

                      // ignore: unnecessary_null_comparison
                      if (user == null) {
                        Get.snackbar(
                          'Login Failed',
                          'Please check your credentials and try again.',
                          backgroundColor: Colors.red.shade300,
                          duration: const Duration(seconds: 2),
                        );
                        return;
                      } else {
                        // Save user data to GetStorage
                        final box = GetStorage();
                        box.erase(); // Clear previous data
                        box.write('userId', user.id);
                        box.write('CurrentUser', user);

                        box.write('isLoggedIn', true);

                        // Show success message and navigate to Home Screen
                        await Get.offAll(
                          () => const MainTabView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 500),
                        );
                        Get.showSnackbar(
                          GetSnackBar(
                            title: 'Login Successful',
                            message: 'Welcome back!',
                            backgroundColor: Colors.green.shade300,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter valid credentials',
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red.shade300,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                child: Text(
                  _authRepo.isLoading.value ? 'Logging in...' : 'L O G I N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
