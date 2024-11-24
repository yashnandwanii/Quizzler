import 'package:get/get.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/views/screens/home_screen.dart';

class OtpController extends GetxController {
  static OtpController get instance => Get.find();

  void verifyOtp(String otp) async {
    var isVerified = await AuthenticationRepository.instance.verifyOtp(otp);
    isVerified ? Get.offAll(const NewhomeScreen()) : Get.back();
  }
}
