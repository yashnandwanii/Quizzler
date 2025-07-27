import 'package:get/get.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/repository/user_repository/user_repository.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthenticationRepository>(AuthenticationRepository(),
        permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
  }
}
