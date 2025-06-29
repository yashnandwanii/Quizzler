import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupControllers extends GetxController {
  static SignupControllers get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();


}
