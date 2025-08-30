import 'package:get/get.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/repository/user_repository/user_repository.dart';
import 'package:quizzler/services/coin_sync_service.dart';

class DependencyInjection {
  static void init() {
    Get.put<AuthenticationRepository>(AuthenticationRepository(),
        permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<CoinSyncService>(CoinSyncService(), permanent: true);
  }
}
