import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupControllers extends GetxController {
  static SignupControllers get instance => Get.find();

  final email = TextEditingController();
  final password = TextEditingController();
  final fullName = TextEditingController();
  final phoneNo = TextEditingController();

  //final userRepo = Get.put(UserRepository());

  // void registerUser(String email, String password) {
  //   AuthenticationRepository.instance
  //       .createUserWithEmailAndPassword(email, password);
  // }

  // void phoneAuthentication(String phoneNo){
  //   AuthenticationRepository.instance.phoneAuthentication(phoneNo);
  // }

  // Future<void> createUser(UserModel user) async {
  //   await userRepo.createUser(user);
  //   phoneAuthentication(user.phoneNo);
  // }
}
