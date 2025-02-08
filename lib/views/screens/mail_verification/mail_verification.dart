import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wallpaper_app/controller/mail_verification_controller.dart';

class MailVerification extends StatelessWidget {
  const MailVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MailVerificationController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail,
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'A verification link has been sent to your email address. Please verify your email to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.manuallyCheckEmailVerification();
                    },
                    child: const Text('Resend Verification Email'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
