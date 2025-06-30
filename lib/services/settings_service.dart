import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class SettingsService extends GetxController {
  final _storage = GetStorage();

  // Game Settings
  final _soundEnabled = true.obs;
  final _vibrationEnabled = true.obs;
  final _notificationsEnabled = true.obs;
  final _darkModeEnabled = false.obs;
  final _autoSubmitEnabled = false.obs;
  final _showHintsEnabled = true.obs;
  final _selectedLanguage = 'English'.obs;
  final _selectedDifficulty = 'Mixed'.obs;
  final _questionTimeLimit = 30.obs;

  // Getters
  bool get soundEnabled => _soundEnabled.value;
  bool get vibrationEnabled => _vibrationEnabled.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get darkModeEnabled => _darkModeEnabled.value;
  bool get autoSubmitEnabled => _autoSubmitEnabled.value;
  bool get showHintsEnabled => _showHintsEnabled.value;
  String get selectedLanguage => _selectedLanguage.value;
  String get selectedDifficulty => _selectedDifficulty.value;
  int get questionTimeLimit => _questionTimeLimit.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _soundEnabled.value = _storage.read('sound_enabled') ?? true;
    _vibrationEnabled.value = _storage.read('vibration_enabled') ?? true;
    _notificationsEnabled.value =
        _storage.read('notifications_enabled') ?? true;
    _darkModeEnabled.value = _storage.read('dark_mode_enabled') ?? false;
    _autoSubmitEnabled.value = _storage.read('auto_submit_enabled') ?? false;
    _showHintsEnabled.value = _storage.read('show_hints_enabled') ?? true;
    _selectedLanguage.value = _storage.read('selected_language') ?? 'English';
    _selectedDifficulty.value = _storage.read('selected_difficulty') ?? 'Mixed';
    _questionTimeLimit.value = _storage.read('question_time_limit') ?? 30;
  }

  void _saveSetting(String key, dynamic value) {
    _storage.write(key, value);
  }

  // Sound Settings
  void toggleSound(bool value) {
    _soundEnabled.value = value;
    _saveSetting('sound_enabled', value);
  }

  // Vibration Settings
  void toggleVibration(bool value) {
    _vibrationEnabled.value = value;
    _saveSetting('vibration_enabled', value);
  }

  // Notification Settings
  void toggleNotifications(bool value) {
    _notificationsEnabled.value = value;
    _saveSetting('notifications_enabled', value);
  }

  // Dark Mode Settings
  void toggleDarkMode(bool value) {
    _darkModeEnabled.value = value;
    _saveSetting('dark_mode_enabled', value);

    // Update theme immediately
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // Auto Submit Settings
  void toggleAutoSubmit(bool value) {
    _autoSubmitEnabled.value = value;
    _saveSetting('auto_submit_enabled', value);
  }

  // Show Hints Settings
  void toggleShowHints(bool value) {
    _showHintsEnabled.value = value;
    _saveSetting('show_hints_enabled', value);
  }

  // Language Settings
  void changeLanguage(String language) {
    _selectedLanguage.value = language;
    _saveSetting('selected_language', language);

    // Update app locale
    Locale locale;
    switch (language) {
      case 'Spanish':
        locale = const Locale('es', 'ES');
        break;
      case 'French':
        locale = const Locale('fr', 'FR');
        break;
      case 'German':
        locale = const Locale('de', 'DE');
        break;
      case 'Italian':
        locale = const Locale('it', 'IT');
        break;
      default:
        locale = const Locale('en', 'US');
    }
    Get.updateLocale(locale);
  }

  // Difficulty Settings
  void changeDifficulty(String difficulty) {
    _selectedDifficulty.value = difficulty;
    _saveSetting('selected_difficulty', difficulty);
  }

  // Time Limit Settings
  void changeTimeLimit(int timeLimit) {
    _questionTimeLimit.value = timeLimit;
    _saveSetting('question_time_limit', timeLimit);
  }

  // Get difficulty level for API calls
  String get difficultyForApi {
    switch (_selectedDifficulty.value) {
      case 'Easy':
        return 'easy';
      case 'Medium':
        return 'medium';
      case 'Hard':
        return 'hard';
      default:
        return 'mixed';
    }
  }

  // Get locale code for API calls
  String get localeCode {
    switch (_selectedLanguage.value) {
      case 'Spanish':
        return 'es';
      case 'French':
        return 'fr';
      case 'German':
        return 'de';
      case 'Italian':
        return 'it';
      default:
        return 'en';
    }
  }

  // Reset all settings to default
  void resetToDefaults() {
    _soundEnabled.value = true;
    _vibrationEnabled.value = true;
    _notificationsEnabled.value = true;
    _darkModeEnabled.value = false;
    _autoSubmitEnabled.value = false;
    _showHintsEnabled.value = true;
    _selectedLanguage.value = 'English';
    _selectedDifficulty.value = 'Mixed';
    _questionTimeLimit.value = 30;

    // Save all defaults
    _saveSetting('sound_enabled', true);
    _saveSetting('vibration_enabled', true);
    _saveSetting('notifications_enabled', true);
    _saveSetting('dark_mode_enabled', false);
    _saveSetting('auto_submit_enabled', false);
    _saveSetting('show_hints_enabled', true);
    _saveSetting('selected_language', 'English');
    _saveSetting('selected_difficulty', 'Mixed');
    _saveSetting('question_time_limit', 30);

    // Reset theme and locale
    Get.changeThemeMode(ThemeMode.light);
    Get.updateLocale(const Locale('en', 'US'));
  }
}
