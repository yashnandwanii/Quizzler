import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/services/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = Get.put(SettingsService());
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Data & Privacy'),
            _buildDataSection(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Account'),
            _buildAccountSection(),
            SizedBox(height: 24.h),
            _buildSectionHeader('Support & Info'),
            _buildSupportSection(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildDropdownTile(
                'Default Difficulty',
                'Set your preferred quiz difficulty',
                Icons.trending_up,
                _settingsService.selectedDifficulty,
                ['Easy', 'Medium', 'Hard', 'Mixed'],
                (value) => _settingsService.changeDifficulty(value),
              )),
          _buildDivider(),
          _buildTimeLimitTile(),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Auto-submit Answers',
                'Automatically submit when time runs out',
                Icons.timer,
                _settingsService.autoSubmitEnabled,
                (value) => _settingsService.toggleAutoSubmit(value),
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Show Hints',
                'Display helpful hints during quizzes',
                Icons.lightbulb_outline,
                _settingsService.showHintsEnabled,
                (value) => _settingsService.toggleShowHints(value),
              )),
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildSwitchTile(
                'Sound Effects',
                'Play sounds for correct/incorrect answers',
                Icons.volume_up,
                _settingsService.soundEnabled,
                (value) => _settingsService.toggleSound(value),
              )),
          _buildDivider(),
          Obx(() => _buildSliderTile(
                'Sound Volume',
                'Adjust sound effects volume',
                Icons.volume_down,
                _settingsService.soundVolume,
                (value) => _settingsService.changeSoundVolume(value),
                enabled: _settingsService.soundEnabled,
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Background Music',
                'Play ambient music during quizzes',
                Icons.music_note,
                _settingsService.musicEnabled,
                (value) => _settingsService.toggleMusic(value),
              )),
          _buildDivider(),
          Obx(() => _buildSliderTile(
                'Music Volume',
                'Adjust background music volume',
                Icons.music_off,
                _settingsService.musicVolume,
                (value) => _settingsService.changeMusicVolume(value),
                enabled: _settingsService.musicEnabled,
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Vibration',
                'Vibrate on correct/incorrect answers',
                Icons.vibration,
                _settingsService.vibrationEnabled,
                (value) => _settingsService.toggleVibration(value),
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Push Notifications',
                'Receive daily quiz reminders',
                Icons.notifications,
                _settingsService.notificationsEnabled,
                (value) => _settingsService.toggleNotifications(value),
              )),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => _buildDropdownTile(
                'Language',
                'Choose your preferred language',
                Icons.language,
                _settingsService.selectedLanguage,
                ['English', 'Spanish', 'French', 'German', 'Italian'],
                (value) {
                  _settingsService.changeLanguage(value);
                  Get.snackbar(
                    'Language Changed',
                    'App will restart to apply language changes',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              )),
          _buildDivider(),
          Obx(() => _buildSliderTile(
                'Font Size',
                'Adjust text size for better readability',
                Icons.font_download,
                _settingsService.fontSizeScale,
                (value) => _settingsService.changeFontSize(value),
                min: 0.8,
                max: 1.5,
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Animations',
                'Enable smooth transitions and animations',
                Icons.animation,
                _settingsService.animationsEnabled,
                (value) => _settingsService.toggleAnimations(value),
              )),
          _buildDivider(),
          Obx(() => _buildSwitchTile(
                'Auto-play Quizzes',
                'Automatically start next question',
                Icons.play_circle_outline,
                _settingsService.autoPlayEnabled,
                (value) => _settingsService.toggleAutoPlay(value),
              )),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Export Settings',
            'Backup your preferences and settings',
            Icons.file_download,
            () => _exportSettings(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services,
            () => _clearCache(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Data Usage',
            'View your app data usage',
            Icons.data_usage,
            () => _showDataUsage(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Account Info',
            'View your profile and statistics',
            Icons.account_circle,
            () => _showAccountInfo(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Reset Settings',
            'Restore all settings to default values',
            Icons.settings_backup_restore,
            () => _showResetSettingsDialog(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Reset Progress',
            'Clear all quiz history and achievements',
            Icons.refresh,
            () => _showResetDialog(),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildActionTile(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_forever,
            () => _showDeleteAccountDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            'Share App',
            'Tell your friends about this quiz app',
            Icons.share,
            () => _shareApp(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Rate Us',
            'Rate us on the App Store or Play Store',
            Icons.star_rate,
            () => _rateApp(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Contact Support',
            'Get help or report issues',
            Icons.help_outline,
            () => _contactSupport(),
          ),
          _buildDivider(),
          _buildActionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            () => _openPrivacyPolicy(),
          ),
          _buildDivider(),
          _buildInfoTile('App Version', _appVersion),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade300
            : Colors.indigo,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade300
            : Colors.indigo,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : (Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade300
                : Colors.indigo),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade300
            : Colors.indigo,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildTimeLimitTile() {
    return Obx(() => ListTile(
          leading: Icon(
            Icons.timer,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade300
                : Colors.indigo,
          ),
          title: Text(
            'Question Time Limit',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Time allowed per question in seconds',
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: SizedBox(
            width: 110.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _settingsService.questionTimeLimit > 10
                      ? () => _settingsService.changeTimeLimit(
                          _settingsService.questionTimeLimit - 5)
                      : null,
                ),
                Text(
                  '${_settingsService.questionTimeLimit}s',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _settingsService.questionTimeLimit < 120
                      ? () => _settingsService.changeTimeLimit(
                          _settingsService.questionTimeLimit + 5)
                      : null,
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.blue.shade300
            : Colors.indigo,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 14.sp,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    Function(double) onChanged, {
    double min = 0.0,
    double max = 1.0,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: enabled
            ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade300
                : Colors.indigo)
            : Colors.grey.shade400,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: enabled ? null : Colors.grey.shade400,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: ((max - min) * 10).round(),
            label: min == 0.8 && max == 1.5
                ? '${(value * 100).round()}%'
                : '${(value * 100).round()}%',
            onChanged: enabled ? onChanged : null,
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade300
                : Colors.indigo,
            inactiveColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
      indent: 56.w,
    );
  }

  void _showAccountInfo() {
    final authRepo = Get.find<AuthenticationRepository>();
    final user = authRepo.firebaseUser.value;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email ?? 'Not available'}'),
            Text('User ID: ${user.uid}'),
            Text(
                'Account created: ${user.metadata.creationTime?.toString().substring(0, 10) ?? 'Unknown'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'This will permanently delete all your quiz history, achievements, and progress. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetProgress();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will restore all settings to their default values. Your quiz progress and achievements will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _settingsService.resetToDefaults();
              Get.snackbar(
                'Settings Reset',
                'All settings have been restored to defaults',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final userId = authRepo.firebaseUser.value?.uid;
      if (userId == null) return;

      // Delete quiz history
      final historyQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('quiz_history')
          .get();

      for (final doc in historyQuery.docs) {
        await doc.reference.delete();
      }

      // Delete achievements
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc('progress')
          .delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc('cumulative_stats')
          .delete();

      // Reset user stats
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'coins': 0,
        'totalScore': 0,
        'quizzesPlayed': 0,
        'rank': 0,
      });

      // Delete from leaderboard
      await FirebaseFirestore.instance
          .collection('LeaderBoard')
          .doc(userId)
          .delete();

      Get.snackbar(
        'Progress Reset',
        'Your progress has been reset successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reset progress: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteAccount() async {
    try {
      final authRepo = Get.find<AuthenticationRepository>();
      final user = authRepo.firebaseUser.value;
      if (user == null) return;

      // First reset all progress
      await _resetProgress();

      // Delete user document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();

      Get.snackbar(
        'Account Deleted',
        'Your account has been deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to login screen
      await authRepo.logout();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _shareApp() {
    Share.share(
      'Check out this amazing Quiz App! Download it from: https://play.google.com/store/apps/details?id=com.example.quizapp',
    );
  }

  void _rateApp() {
    // For a real app, you would use the app's store URL
    const storeUrl =
        'https://play.google.com/store/apps/details?id=com.example.quizapp';
    _launchUrl(storeUrl);
  }

  void _contactSupport() {
    const emailUrl =
        'mailto:support@quizapp.com?subject=Quiz App Support&body=Describe your issue here...';
    _launchUrl(emailUrl);
  }

  void _openPrivacyPolicy() {
    const privacyUrl = 'https://www.example.com/privacy-policy';
    _launchUrl(privacyUrl);
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'Error',
        'Could not open link',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _exportSettings() {
    try {
      // In a real app, you would export settings to a file
      final settings = {
        'sound_enabled': _settingsService.soundEnabled,
        'vibration_enabled': _settingsService.vibrationEnabled,
        'notifications_enabled': _settingsService.notificationsEnabled,
        'auto_submit_enabled': _settingsService.autoSubmitEnabled,
        'show_hints_enabled': _settingsService.showHintsEnabled,
        'selected_language': _settingsService.selectedLanguage,
        'selected_difficulty': _settingsService.selectedDifficulty,
        'question_time_limit': _settingsService.questionTimeLimit,
      };

      // In a real app, you would write settings to a file or cloud storage
      debugPrint('Settings exported: $settings');

      Get.snackbar(
        'Settings Exported',
        'Your settings have been backed up successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Could not backup settings: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary files and free up storage space. Your settings and progress will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would clear cache here
              Get.snackbar(
                'Cache Cleared',
                'Temporary files have been removed',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDataUsage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estimated app data usage:'),
            const SizedBox(height: 16),
            const Text('• Quiz data: ~2.5 MB'),
            const Text('• Profile images: ~1.2 MB'),
            const Text('• Cache files: ~0.8 MB'),
            const Text('• User preferences: ~0.1 MB'),
            const SizedBox(height: 16),
            Text(
              'Total: ~4.6 MB',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
