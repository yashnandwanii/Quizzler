// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:wallpaper_app/repository/authentication_repository/exceptions/signup_email_password.dart';
// import 'package:wallpaper_app/views/screens/home_screen.dart';
// import 'package:wallpaper_app/views/screens/signup/signup_screen.dart';

// class AuthenticationRepository extends GetxController {
//   static AuthenticationRepository get instance => Get.find();

//   // variables
//   final _auth = FirebaseAuth.instance;
//   Rx<User?> firebaseUser = Rx<User?>(FirebaseAuth.instance.currentUser);

//   var verificationId = ''.obs;

//   // constructor
//   @override
//   void onReady() {
//     firebaseUser = Rx<User?>(_auth.currentUser);
//     firebaseUser.bindStream(_auth.userChanges());
//     ever(firebaseUser, _setInitialScreen);
//   }

//   _setInitialScreen(User? user) {
//     user == null
//         ? Get.offAll(() => SignupScreen())
//         : Get.offAll(() => NewhomeScreen());
//   }

//   void phoneAuthentication(String phoneNo) async {
//     try {
//       // Validate the phone number format to ensure it's in E.164 format
//       final formattedPhoneNo = phoneNo.startsWith('+') ? phoneNo : '+$phoneNo';
//       debugPrint('Attempting phone authentication with: $formattedPhoneNo');

//       await _auth.verifyPhoneNumber(
//         phoneNumber: formattedPhoneNo,
//         verificationCompleted: (credentials) async {
//           // Automatically sign in when verification is completed successfully
//           try {
//             await _auth.signInWithCredential(credentials);
//             Get.snackbar('Success', 'Phone number verified and signed in!');
//           } catch (signInError) {
//             debugPrint('Sign-in error: $signInError');
//             Get.snackbar('Error', 'Failed to sign in with credentials.');
//           }
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           // Handle specific errors more gracefully
//           switch (e.code) {
//             case 'invalid-phone-number':
//               Get.snackbar('Error', 'The provided phone number is invalid.');
//               break;
//             case 'too-many-requests':
//               Get.snackbar('Error', 'Too many requests. Try again later.');
//               break;
//             default:
//               Get.snackbar('Error', e.message ?? 'An unknown error occurred.');
//           }
//           debugPrint('Verification failed: ${e.code} - ${e.message}');
//         },
//         codeSent: (verificationId, resendToken) {
//           // Save the verificationId to be used later for manual verification
//           this.verificationId.value = verificationId;
//           Get.snackbar('Info', 'OTP sent to $formattedPhoneNo');
//           debugPrint('Code sent with verificationId: $verificationId');
//         },
//         codeAutoRetrievalTimeout: (verificationId) {
//           // Handle auto-retrieval timeout
//           this.verificationId.value = verificationId;
//           debugPrint(
//               'Auto-retrieval timeout with verificationId: $verificationId');
//         },
//       );
//     } catch (e) {
//       // Handle any unexpected errors that might occur
//       debugPrint('Unexpected phone authentication error: $e');
//       Get.snackbar('Error', 'Failed to verify phone number. Please try again.');
//     }
//   }

//   Future<bool> verifyOtp(String otp) async {
//     try {
//       var credentials = await _auth.signInWithCredential(
//         PhoneAuthProvider.credential(
//           verificationId: verificationId.value,
//           smsCode: otp,
//         ),
//       );
//       return credentials.user != null;
//     } catch (e) {
//       Get.snackbar('Error', 'Invalid OTP. Please try again.');
//       debugPrint('OTP Verification Error: $e');
//       return false;
//     }
//   }

//   Future<void> createUserWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//     } on FirebaseException catch (e) {
//       Get.snackbar('Error', e.message ?? 'An error occurred');
//     }
//   }

//   Future<void> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       await _auth.signInWithEmailAndPassword(email: email, password: password);
//     } on FirebaseException catch (e) {
//       final ex = SignupWithEmailAndPasswordFailure.code(e.code);
//       debugPrint('Firebase Auth Exception - ${ex.message}');
//       throw ex;
//     }
//   }

//   Future<void> logout() async => await _auth.signOut();
// }
