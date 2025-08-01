import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final RxBool isObscure;
  final IconData icon;

  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isObscure,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller,
        obscureText: isObscure.value,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters long';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          fillColor: Colors.white,
          prefixIcon: Icon(icon),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure.value ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              isObscure.value = !isObscure.value;
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      ),
    );
  }
}
