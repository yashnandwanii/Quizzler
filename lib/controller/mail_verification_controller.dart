import 'dart:async';

import 'package:get/get.dart';

class MailVerificationController extends GetxController {
  late Timer _timer;
  
  // void onInit() {
  //   // TODO: implement onInit
  //   super.onInit();
  //   sendVerificationEmail();
  //   setTimerForAutoRedirect();
  // }

  // void sendVerificationEmail() async {
  //   // Send verification email to the user
  //   try {
  //     await AuthenticationRepository.instance.sendEmailVerification();
  //   } catch (e) {
  //     SnackBar(content: Text('Failed to send verification email: $e'));
  //   }
  // }

  // void setTimerForAutoRedirect() {
  //   _timer = Timer.periodic(
  //     Duration(seconds: 3),
  //     (timer) {
  //       // Check if the user has verified their email
  //       FirebaseAuth.instance.currentUser!.reload();
  //       final user = FirebaseAuth.instance.currentUser;
  //       if (user!.emailVerified) {
  //         // If email is verified, redirect to the home screen
          
  //         timer.cancel();
  //         AuthenticationRepository.instance.setInitialScreen(user);
  //       }
  //     },
  //   );
  // }

  void manuallyCheckEmailVerification() {}
}
