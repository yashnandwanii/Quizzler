// ignore_for_file: unnecessary_null_comparison

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/views/home/main_tab_view.dart';
import 'package:quizzler/views/signup/widgets/password_field.dart';
import 'package:quizzler/views/widgets/rount_text_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final AuthenticationRepository _authRepo =
      Get.put(AuthenticationRepository());

  @override
  Widget build(BuildContext context) {
    final RxBool isPasswordHidden = true.obs;
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundTextField(
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter your full name';
              }
              // Simple validation for full name
              if (value.length < 3) {
                return 'Full name must be at least 3 characters';
              }
              return null;
            },
            controller: _fullNameController,
            hintText: 'Enter your full name',
            labelText: 'Full Name',
            icon: Icons.person,
          ),
          SizedBox(
            height: 10.h,
          ),
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
            controller: _emailController,
            hintText: 'Enter your mail',
            labelText: 'Email',
            icon: Icons.email,
          ),
          SizedBox(
            height: 10.h,
          ),
          PasswordField(
            controller: _passwordController,
            hintText: 'Enter a Password',
            labelText: 'Password',
            icon: Icons.lock,
            isObscure: isPasswordHidden,
          ),
          SizedBox(
            height: 20.h,
          ),
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
                  if (EmailValidator.validate(_emailController.text) &&
                      _passwordController.text.isNotEmpty &&
                      _fullNameController.text.isNotEmpty) {
                    if (formKey.currentState!.validate()) {
                      try {
                        final user =
                            await _authRepo.createUserWithEmailAndPassword(
                          _emailController.text,
                          _passwordController.text,
                          _fullNameController.text,
                        );

                        debugPrint(user.toString());

                        if (user == null) {
                          Get.snackbar(
                            'Sign Up Failed',
                            'Please check your credentials and try again.',
                            backgroundColor: Colors.red.shade300,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                          return;
                        } else {
                          final box = GetStorage();
                          box.erase();
                          box.write('userId', user.id);
                          box.write('email', _emailController.text);

                          box.write('fullName', _fullNameController.text);

                          _authRepo.isLoading.value = false;
                          _emailController.clear();
                          _passwordController.clear();
                          _fullNameController.clear();

                          Get.offAll(
                            () => const MainTabView(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 500),
                          );
                          Future.delayed(const Duration(milliseconds: 600), () {
                            Get.snackbar(
                              'Sign Up Successful',
                              'Welcome to the app!',
                              backgroundColor: Colors.green.shade300,
                              duration: const Duration(seconds: 2),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          });
                        }
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter valid credentials',
                      backgroundColor: Colors.red.shade300,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: Text(
                  _authRepo.isLoading.value ? 'Signing Up...' : 'S I G N  U P',
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
