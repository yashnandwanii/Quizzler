import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/model/user_model.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      debugPrint('Creating user document for ID: ${user.id}');
      await _db.collection("users").doc(user.id).set(user.toJson());
      debugPrint('User document created successfully');
    } catch (e) {
      debugPrint('Error creating user document: $e');
      Get.snackbar(
        "Error",
        "Something went wrong. Try again",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
      debugPrint(e.toString());
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      debugPrint('Fetching user data for ID: $userId');
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        debugPrint('User document found');
        final data = doc.data()!;
        debugPrint('User data: $data');
        return UserModel.fromJson(data);
      } else {
        debugPrint('User document does not exist for ID: $userId');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      Get.snackbar('Error', 'Failed to fetch user data: $e');
    }
    return null;
  }

  Future<void> updateUserRecord(UserModel user) async {
    try {
      await _db.collection("users").doc(user.id).update(user.toJson());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Try again",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _db.collection("users").doc(user.id).update(user.toJson());
      return true;
    } catch (e) {
      Get.snackbar("Error", "Something went wrong. Try again",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
          colorText: Colors.red);
      return false;
    }
  }
}
