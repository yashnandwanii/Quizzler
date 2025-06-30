import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.labelText,
    required this.isObscure,
    this.icon,
  });

  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final IconData? icon;
  final RxBool isObscure;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        validator: (value) => value!.isEmpty
            ? 'Please enter a password'
            : value.length < 8
                ? 'Password must be at least 6 characters'
                : null,
        obscureText: isObscure.value,
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(
              isObscure.value ? Icons.visibility : Icons.visibility_off,
              color: Colors.blue,
            ),
            onPressed: () {
              isObscure.value = !isObscure.value;
            },
          ),
          prefixIcon: icon != null
              ? Icon(
                  icon,
                  color: Colors.blue,
                )
              : null,
          labelText: labelText,
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
