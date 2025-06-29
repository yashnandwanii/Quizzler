import 'package:get/get.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthenticationRepository>(AuthenticationRepository(),
        permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
  }
}
