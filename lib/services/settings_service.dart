import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsService extends GetxController {
  final _storage = GetStorage();

  // Game Settings
  final _soundEnabled = true.obs;
  final _musicEnabled = true.obs;
  final _vibrationEnabled = true.obs;
  final _notificationsEnabled = true.obs;
  final _autoSubmitEnabled = false.obs;
  final _showHintsEnabled = true.obs;
  final _selectedLanguage = 'English'.obs;
  final _selectedDifficulty = 'Mixed'.obs;
  final _questionTimeLimit = 30.obs;
  final _soundVolume = 0.7.obs;
  final _musicVolume = 0.5.obs;
  final _fontSizeScale = 1.0.obs;
  final _animationsEnabled = true.obs;
  final _autoPlayEnabled = false.obs;

  // Getters
  bool get soundEnabled => _soundEnabled.value;
  bool get musicEnabled => _musicEnabled.value;
  bool get vibrationEnabled => _vibrationEnabled.value;
  bool get notificationsEnabled => _notificationsEnabled.value;
  bool get autoSubmitEnabled => _autoSubmitEnabled.value;
  bool get showHintsEnabled => _showHintsEnabled.value;
  String get selectedLanguage => _selectedLanguage.value;
  String get selectedDifficulty => _selectedDifficulty.value;
  int get questionTimeLimit => _questionTimeLimit.value;
  double get soundVolume => _soundVolume.value;
  double get musicVolume => _musicVolume.value;
  double get fontSizeScale => _fontSizeScale.value;
  bool get animationsEnabled => _animationsEnabled.value;
  bool get autoPlayEnabled => _autoPlayEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    _soundEnabled.value = _storage.read('sound_enabled') ?? true;
    _musicEnabled.value = _storage.read('music_enabled') ?? true;
    _vibrationEnabled.value = _storage.read('vibration_enabled') ?? true;
    _notificationsEnabled.value =
        _storage.read('notifications_enabled') ?? true;
    _autoSubmitEnabled.value = _storage.read('auto_submit_enabled') ?? false;
    _showHintsEnabled.value = _storage.read('show_hints_enabled') ?? true;
    _selectedLanguage.value = _storage.read('selected_language') ?? 'English';
    _selectedDifficulty.value = _storage.read('selected_difficulty') ?? 'Mixed';
    _questionTimeLimit.value = _storage.read('question_time_limit') ?? 30;
    _soundVolume.value = _storage.read('sound_volume') ?? 0.7;
    _musicVolume.value = _storage.read('music_volume') ?? 0.5;
    _fontSizeScale.value = _storage.read('font_size_scale') ?? 1.0;
    _animationsEnabled.value = _storage.read('animations_enabled') ?? true;
    _autoPlayEnabled.value = _storage.read('auto_play_enabled') ?? false;
  }

  void _saveSetting(String key, dynamic value) {
    _storage.write(key, value);
  }

  // Sound Settings
  void toggleSound(bool value) {
    _soundEnabled.value = value;
    _saveSetting('sound_enabled', value);
    if (value) {
      playSound('toggle');
    }
  }

  // Music Settings
  void toggleMusic(bool value) {
    _musicEnabled.value = value;
    _saveSetting('music_enabled', value);
    // TODO: Implement background music control
  }

  // Vibration Settings
  void toggleVibration(bool value) {
    _vibrationEnabled.value = value;
    _saveSetting('vibration_enabled', value);
    if (value) {
      triggerVibration();
    }
  }

  // Notification Settings
  void toggleNotifications(bool value) {
    _notificationsEnabled.value = value;
    _saveSetting('notifications_enabled', value);
    // TODO: Request/cancel notification permissions
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

  // Animations Settings
  void toggleAnimations(bool value) {
    _animationsEnabled.value = value;
    _saveSetting('animations_enabled', value);
  }

  // Auto Play Settings
  void toggleAutoPlay(bool value) {
    _autoPlayEnabled.value = value;
    _saveSetting('auto_play_enabled', value);
  }

  // Volume Settings
  void changeSoundVolume(double volume) {
    _soundVolume.value = volume;
    _saveSetting('sound_volume', volume);
    playSound('volume_test');
  }

  void changeMusicVolume(double volume) {
    _musicVolume.value = volume;
    _saveSetting('music_volume', volume);
    // TODO: Update background music volume
  }

  // Font Size Settings
  void changeFontSize(double scale) {
    _fontSizeScale.value = scale;
    _saveSetting('font_size_scale', scale);
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

  // Utility Methods
  void playSound(String soundName) {
    if (_soundEnabled.value) {
      // TODO: Implement sound playing
      SystemSound.play(SystemSoundType.click);
    }
  }

  void triggerVibration() {
    if (_vibrationEnabled.value) {
      HapticFeedback.lightImpact();
    }
  }

  void triggerHeavyVibration() {
    if (_vibrationEnabled.value) {
      HapticFeedback.heavyImpact();
    }
  }

  void triggerSelectionVibration() {
    if (_vibrationEnabled.value) {
      HapticFeedback.selectionClick();
    }
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
    _musicEnabled.value = true;
    _vibrationEnabled.value = true;
    _notificationsEnabled.value = true;
    _autoSubmitEnabled.value = false;
    _showHintsEnabled.value = true;
    _selectedLanguage.value = 'English';
    _selectedDifficulty.value = 'Mixed';
    _questionTimeLimit.value = 30;
    _soundVolume.value = 0.7;
    _musicVolume.value = 0.5;
    _fontSizeScale.value = 1.0;
    _animationsEnabled.value = true;
    _autoPlayEnabled.value = false;

    // Save all defaults
    _saveSetting('sound_enabled', true);
    _saveSetting('music_enabled', true);
    _saveSetting('vibration_enabled', true);
    _saveSetting('notifications_enabled', true);
    _saveSetting('auto_submit_enabled', false);
    _saveSetting('show_hints_enabled', true);
    _saveSetting('selected_language', 'English');
    _saveSetting('selected_difficulty', 'Mixed');
    _saveSetting('question_time_limit', 30);
    _saveSetting('sound_volume', 0.7);
    _saveSetting('music_volume', 0.5);
    _saveSetting('font_size_scale', 1.0);
    _saveSetting('animations_enabled', true);
    _saveSetting('auto_play_enabled', false);

    // Reset locale
    Get.updateLocale(const Locale('en', 'US'));
  }
}
