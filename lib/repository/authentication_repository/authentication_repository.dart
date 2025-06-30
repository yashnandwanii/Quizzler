import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/views/home/main_tab_view.dart';
import 'package:wallpaper_app/views/screens/quiz_splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);
  final box = GetStorage();
  final RxString verificationId = ''.obs;
  final RxBool _isLoading = false.obs;

  RxBool get isLoading => _isLoading;

  @override
  void onReady() {
    firebaseUser.bindStream(_auth.userChanges());
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore, if not, create a new user document
        final userRepo = Get.find<UserRepository>();
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!doc.exists) {
          final newUser = UserModel(
              id: user.uid,
              email: user.email ?? '',
              fullName: user.displayName ?? 'No Name',
              photoUrl: user.photoURL ?? '',
              password: "" // Not needed for Google Sign-In
              );
          await userRepo.createUser(newUser);
          Get.offAll(
            () => const MainTabView(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 500),
          );
        }
      }
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      Get.snackbar('Error', 'Google Sign-In failed. Please try again.');
      return null;
    }
  }

  Future<UserModel?> createUserWithEmailAndPassword(
      String email, String password, String fullName) async {
    _isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('User creation failed');
        return null;
      }
      final userModel = UserModel(
        id: user.uid,
        email: email,
        password: password,
        fullName: fullName,
        photoUrl:
            'https://res.cloudinary.com/damn70nxv/image/upload/v1751261851/men4_wcjrla.png',
        coins: 0,
        rank: 0,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());
      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign-up error: ${e.code} - ${e.message}');
      String message = switch (e.code) {
        'email-already-in-use' =>
          'This email is already in use. Please log in instead.',
        'invalid-email' => 'The email address is invalid.',
        'weak-password' =>
          'Your password is too weak. Please use a stronger password.',
        'operation-not-allowed' => 'Email/password accounts are not enabled.',
        _ => e.message ?? 'An unknown error occurred.',
      };
      Get.snackbar(
        'Signup Failed',
        message,
        backgroundColor: Colors.redAccent,
      );
      return null;
    } catch (e) {
      debugPrint('Unexpected sign-up error: $e');
      Get.snackbar('Error', 'Something went wrong. Try again.');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      } else {
        debugPrint('No user found with ID: $userId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      Get.snackbar('Error', 'Failed to fetch user data.');
      return null;
    }
  }

  Future<void> saveUserDataToDb(
      String email, String password, String fullName) async {
    try {
      final userModel = UserModel(
        email: email,
        password: password,
        fullName: fullName,
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .set(userModel.toJson(), SetOptions(merge: true));
      debugPrint(
          'User data saved to Firestore for user ID: ${_auth.currentUser?.uid}');
    } catch (e) {
      debugPrint('Error saving user data to Firestore: $e');
      Get.snackbar('Error', 'Failed to save user data.');
    }
  }

  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    _isLoading.value = true;
    try {
      final res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      debugPrint('Login successful for user: ${res.user?.email}');
      final user = res.user;
      return UserModel(
        id: user?.uid ?? '',
        email: user?.email ?? '',
        fullName: user?.displayName ?? '',
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Login error: ${e.code} - ${e.message}');
      String message = switch (e.code) {
        'user-not-found' => 'User not found. Please sign up.',
        'wrong-password' => 'Wrong password. Try again.',
        'invalid-email' => 'Invalid email address.',
        'network-request-failed' =>
          'Network error. Please check your internet connection.',
        _ => e.message ?? 'An unknown error occurred.',
      };
      Get.snackbar('Login Failed', message, backgroundColor: Colors.redAccent);
      return null;
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      Get.snackbar('Error', 'Unexpected error. Try again.');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      box.erase(); // Clear stored user data
      firebaseUser.value = null; // Update the observable
      debugPrint('User logged out successfully');
      Get.offAll(
        () => const QuizSplashScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 500),
      );
      Get.snackbar('Logged Out', 'You have been signed out.');
    } catch (e) {
      debugPrint('Logout error: $e');
      Get.snackbar('Error', 'Logout failed. Try again.');
    }
  }
}
