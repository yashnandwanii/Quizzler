import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quizzler/services/settings_service.dart';

class NotificationService extends GetxController {
  final SettingsService _settingsService = Get.find<SettingsService>();

  // Check if notifications are enabled
  bool get areNotificationsEnabled => _settingsService.notificationsEnabled;

  // Request notification permissions (placeholder for actual implementation)
  Future<bool> requestNotificationPermission() async {
    try {
      // In a real app, you would request permissions here
      // For now, we'll just update the settings
      if (!areNotificationsEnabled) {
        _settingsService.toggleNotifications(true);

        Get.snackbar(
          'Notifications Enabled',
          'You will now receive daily quiz reminders',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } catch (e) {
      Get.snackbar(
        'Permission Error',
        'Could not enable notifications',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // Schedule daily reminder (placeholder for actual implementation)
  Future<void> scheduleDailyReminder() async {
    if (!areNotificationsEnabled) return;

    // In a real app, you would use packages like:
    // - flutter_local_notifications
    // - awesome_notifications
    // - firebase_messaging for push notifications

    debugPrint('Daily reminder scheduled for quiz app');
  }

  // Cancel notifications
  Future<void> cancelNotifications() async {
    // In a real app, you would cancel all scheduled notifications here
    _settingsService.toggleNotifications(false);

    Get.snackbar(
      'Notifications Disabled',
      'Daily reminders have been turned off',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Send achievement notification (for when user unlocks achievements)
  void sendAchievementNotification(String title, String description) {
    if (!areNotificationsEnabled) return;

    Get.snackbar(
      '🏆 $title',
      description,
      backgroundColor: Colors.amber,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Send quiz reminder notification
  void sendQuizReminder() {
    if (!areNotificationsEnabled) return;

    Get.snackbar(
      '🧠 Quiz Time!',
      'Ready to test your knowledge? Play a quiz now!',
      backgroundColor: Colors.indigo,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // Show notification settings explanation
  void showNotificationInfo() {
    Get.dialog(
      AlertDialog(
        title: const Text('About Notifications'),
        content: const Text(
          'Notifications help you stay engaged with the quiz app:\n\n'
          '• Daily quiz reminders\n'
          '• Achievement unlocks\n'
          '• Weekly progress summaries\n'
          '• Challenge completions\n\n'
          'You can disable them anytime in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Got it'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              requestNotificationPermission();
            },
            child: const Text('Enable Notifications'),
          ),
        ],
      ),
    );
  }
}
