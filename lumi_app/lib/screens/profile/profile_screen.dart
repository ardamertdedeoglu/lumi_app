import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/pregnancy_model.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/pregnancy_info_card.dart';
import '../../widgets/profile/settings_menu_item.dart';
import '../../widgets/shared/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = UserModel.demo;
    final pregnancy = PregnancyModel.demo;

    // Calculate last period date from expected due date
    final lastPeriodDate = pregnancy.expectedDueDate.subtract(const Duration(days: 280));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Profile Header
          ProfileHeader(
            user: user,
            weekInfo: '${pregnancy.currentWeek}. Hafta',
          ),

          const SizedBox(height: 28),

          // Section: Pregnancy Info
          const SectionHeader(title: AppStrings.pregnancyInfo),

          const SizedBox(height: 16),

          // Pregnancy Info Card
          PregnancyInfoCard(
            lastPeriodDate: lastPeriodDate,
            expectedDueDate: pregnancy.expectedDueDate,
            doctorName: 'Dr. Ayşe Yılmaz',
          ),

          const SizedBox(height: 28),

          // Section: Settings
          const SectionHeader(title: AppStrings.settings),

          const SizedBox(height: 16),

          // Settings Menu
          SettingsMenuCard(
            items: [
              SettingsMenuItem(
                icon: FontAwesomeIcons.bell,
                title: AppStrings.notifications,
                subtitle: _notificationsEnabled ? 'Açık' : 'Kapalı',
                iconColor: AppColors.primaryPink,
                type: SettingsItemType.toggle,
                toggleValue: _notificationsEnabled,
                onToggleChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SettingsMenuItem(
                icon: themeProvider.isDarkMode
                    ? FontAwesomeIcons.moon
                    : FontAwesomeIcons.sun,
                title: AppStrings.theme,
                subtitle: themeProvider.isDarkMode
                    ? AppStrings.darkMode
                    : AppStrings.lightMode,
                iconColor: AppColors.primaryPurple,
                type: SettingsItemType.navigation,
                onTap: () {
                  themeProvider.toggleTheme();
                },
              ),
              SettingsMenuItem(
                icon: FontAwesomeIcons.language,
                title: AppStrings.language,
                subtitle: AppStrings.turkish,
                iconColor: AppColors.primaryBlue,
                type: SettingsItemType.navigation,
                onTap: () {
                  // Language selection
                },
              ),
              SettingsMenuItem(
                icon: FontAwesomeIcons.circleInfo,
                title: AppStrings.aboutApp,
                iconColor: AppColors.green,
                type: SettingsItemType.navigation,
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Section: Account
          const SectionHeader(title: AppStrings.account),

          const SizedBox(height: 16),

          // Account Actions
          SettingsMenuCard(
            items: [
              SettingsMenuItem(
                icon: FontAwesomeIcons.fileExport,
                title: AppStrings.exportData,
                iconColor: AppColors.primaryBlue,
                type: SettingsItemType.navigation,
                onTap: () {
                  // Export data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Veriler dışa aktarılıyor...'),
                      backgroundColor: colors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              SettingsMenuItem(
                icon: FontAwesomeIcons.rightFromBracket,
                title: AppStrings.logout,
                iconColor: AppColors.red,
                type: SettingsItemType.navigation,
                onTap: () {
                  // Logout
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Version Footer
          Center(
            child: Text(
              '${AppStrings.version} 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.baby,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lumi, hamilelik sürecinizi takip etmenize yardımcı olan kişisel asistanınızdır.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${AppStrings.version} 1.0.0',
              style: TextStyle(
                fontSize: 13,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
