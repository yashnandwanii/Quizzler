import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallpaper_app/model/user_model.dart';
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
        }
      }
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      Get.snackbar('Error', 'Google Sign-In failed. Please try again.');
      return null;
    }
  }

  // ---------------- PHONE AUTH ----------------
  Future<void> phoneAuthentication(String phoneNo) async {
    try {
      final formattedPhoneNo = phoneNo.startsWith('+') ? phoneNo : '+$phoneNo';
      debugPrint('Attempting phone authentication: $formattedPhoneNo');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNo,
        verificationCompleted: (PhoneAuthCredential credentials) async {
          try {
            await _auth.signInWithCredential(credentials);
            Get.snackbar('Success', 'Phone number verified automatically.');
          } catch (signInError) {
            debugPrint('Auto sign-in error: $signInError');
            Get.snackbar('Error', 'Automatic sign-in failed.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.code} - ${e.message}');
          String message = switch (e.code) {
            'invalid-phone-number' => 'Invalid phone number.',
            'too-many-requests' => 'Too many requests. Try again later.',
            _ => e.message ?? 'Something went wrong.',
          };
          Get.snackbar('Phone Auth Error', message,
              backgroundColor: Colors.redAccent);
        },
        codeSent: (String id, int? resendToken) {
          verificationId.value = id;
          debugPrint('OTP sent. verificationId: $id');
          Get.snackbar('OTP Sent', 'Code sent to $formattedPhoneNo');
        },
        codeAutoRetrievalTimeout: (String id) {
          verificationId.value = id;
          debugPrint('Code auto-retrieval timeout. ID: $id');
        },
      );
    } catch (e) {
      debugPrint('Unexpected error in phoneAuthentication: $e');
      Get.snackbar('Error', 'Something went wrong. Try again.');
    }
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        Get.snackbar('Success', 'OTP verified successfully');
        return true;
      } else {
        Get.snackbar('Error', 'OTP verification failed.');
        return false;
      }
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      Get.snackbar('Error', 'Invalid OTP or verification expired.');
      return false;
    }
  }

  Future<UserModel> createUserWithEmailAndPassword(
      String email, String password, String fullName) async {
    _isLoading.value = true;
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = _auth.currentUser;
      if (user == null) {
        throw SignUpEmailPasswordException('User creation failed');
      }
      final userModel = UserModel(
        id: user.uid,
        email: email,
        password: password,
        fullName: fullName,
        photoUrl: '',
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
      Get.snackbar(
        'Signup Failed',
        e.message ?? 'An unknown error occurred.',
        backgroundColor: Colors.redAccent,
      );
      throw SignUpEmailPasswordException(
          e.message ?? 'An unknown error occurred.');
    } catch (e) {
      debugPrint('Unexpected sign-up error: $e');
      Get.snackbar('Error', 'Something went wrong. Try again.');
      throw SignUpEmailPasswordException('Something went wrong. Try again.');
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

// Custom exception (optional)
class SignUpEmailPasswordException implements Exception {
  final String message;
  SignUpEmailPasswordException(this.message);
  @override
  String toString() => message;
}
