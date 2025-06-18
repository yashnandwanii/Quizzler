// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wallpaper_app/model/user_model.dart';

// class UserRepository extends GetxController {
//   static UserRepository get instance => Get.find();

  

//   createUser(UserModel user) async {
    
//   }

//   Future<UserModel> getUserDetails(String email) async {
//     final snapshot =
//         await _db.collection('Users').where('Email', isEqualTo: email).get();
//     final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;

//     return userData;
//   }

//   Future<List<UserModel>> allUser(String email) async {
//     final snapshot = await _db.collection('Users').get();
//     final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();

//     return userData;
//   }
// }
