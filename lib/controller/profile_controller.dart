import 'package:get/get.dart';
import 'package:wallpaper_app/model/user_model.dart';
import 'package:wallpaper_app/repository/authentication_repository/authentication_repository.dart';
import 'package:wallpaper_app/repository/user_repository/user_repository.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  final _authRepo = Get.put(AuthenticationRepository());
  final _userRepo = Get.put(UserRepository());

  // Fetch user data based on authenticated user's email
  Future<UserModel?> getUserData() async {
    try {
      final email = _authRepo.firebaseUser.value?.email;

      if (email != null) {
        // If the email exists, fetch user details
        return await _userRepo.getUserDetails(email);
      } else {
        // If no email found, show snackbar and return null
        Get.snackbar('Error', 'Please login to continue');
        return null; // Return null as user is not authenticated
      }
    } catch (e) {
      // If any error occurs during the fetch, show an error message
      Get.snackbar('Error', 'Failed to fetch user data: $e');
      return null; // Return null in case of an error
    }
  }

  // Fetch all users (useful for admins or user management)
  Future<List<UserModel>> getAllUser() async {
    try {
      return await _userRepo.allUser('users');
    } catch (e) {
      // Handle the case where fetching all users fails
      Get.snackbar('Error', 'Failed to fetch all users: $e');
      return []; // Return an empty list if there is an error
    }
  }
}
