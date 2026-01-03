import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/profile/settings_menu_item.dart';
import '../../widgets/shared/section_header.dart';
import 'edit_profile_screen.dart';
import 'edit_pregnancy_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  FullProfile? _fullProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _profileService.getFullProfile();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess && result.data != null) {
          _fullProfile = result.data;
          _notificationsEnabled = result.data!.profile.notificationsEnabled;
        } else {
          _errorMessage = result.errorMessage;
        }
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    
    final result = await _profileService.updateProfile(
      notificationsEnabled: value,
    );

    if (!result.isSuccess && mounted) {
      setState(() => _notificationsEnabled = !value); // Geri al
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Ayar güncellenemedi'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Çıkış Yap',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Text(
          'Çıkış yapmak istediğinize emin misiniz?',
          style: TextStyle(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: context.colors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Çıkış Yap',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      // Ana ekrana dönüş için uygulama yeniden başlatılmalı
      // Bu işlem main.dart'taki state ile yönetilecek
    }
  }

  void _editProfile() {
    if (_fullProfile == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          profile: _fullProfile!.profile,
          onSaved: _loadProfile,
        ),
      ),
    );
  }

  void _editPregnancy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPregnancyScreen(
          pregnancy: _fullProfile?.pregnancy,
          onSaved: _loadProfile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primaryPink,
            ),
            const SizedBox(height: 16),
            Text(
              'Profil yükleniyor...',
              style: TextStyle(color: colors.textTertiary),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.circleExclamation,
                size: 48,
                color: colors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _fullProfile!.profile;
    final pregnancy = _fullProfile!.pregnancy;
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Profile Header
            _buildProfileHeader(context, profile, pregnancy),

            const SizedBox(height: 28),

            // Section: Pregnancy Info
            const SectionHeader(title: AppStrings.pregnancyInfo),

            const SizedBox(height: 16),

            // Pregnancy Info Card veya Oluştur Butonu
            if (pregnancy != null)
              _buildPregnancyInfoCard(context, pregnancy, dateFormat)
            else
              _buildCreatePregnancyCard(context),

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
                  onToggleChanged: _toggleNotifications,
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
                  onTap: () => themeProvider.toggleTheme(),
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.language,
                  title: AppStrings.language,
                  subtitle: AppStrings.turkish,
                  iconColor: AppColors.primaryBlue,
                  type: SettingsItemType.navigation,
                  onTap: () {},
                ),
                SettingsMenuItem(
                  icon: FontAwesomeIcons.circleInfo,
                  title: AppStrings.aboutApp,
                  iconColor: AppColors.green,
                  type: SettingsItemType.navigation,
                  onTap: () => _showAboutDialog(context),
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
                  onTap: _logout,
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
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileData profile, PregnancyData? pregnancy) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with gradient border
          Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colors.card,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.user,
                  size: 32,
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.fullName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🤰', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 8),
          // Week info badge
          if (pregnancy != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                pregnancy.weekLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hamilelik bilgisi girilmedi',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textTertiary,
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Edit Profile Button
          OutlinedButton.icon(
            onPressed: _editProfile,
            icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
            label: const Text('Profili Düzenle'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryPink,
              side: const BorderSide(color: AppColors.primaryPink),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyInfoCard(BuildContext context, PregnancyData pregnancy, DateFormat dateFormat) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPregnancyInfoItem(
            context,
            icon: FontAwesomeIcons.calendarDay,
            label: AppStrings.lastPeriodDate,
            value: dateFormat.format(pregnancy.lastPeriodDate),
            iconColor: AppColors.primaryPink,
          ),
          Divider(color: colors.border, height: 1, indent: 70),
          _buildPregnancyInfoItem(
            context,
            icon: FontAwesomeIcons.baby,
            label: AppStrings.expectedDueDate,
            value: dateFormat.format(pregnancy.expectedDueDate),
            iconColor: AppColors.primaryPurple,
          ),
          if (pregnancy.doctorName != null && pregnancy.doctorName!.isNotEmpty) ...[
            Divider(color: colors.border, height: 1, indent: 70),
            _buildPregnancyInfoItem(
              context,
              icon: FontAwesomeIcons.userDoctor,
              label: AppStrings.doctor,
              value: pregnancy.doctorName!,
              iconColor: AppColors.primaryBlue,
            ),
          ],
          // Edit Pregnancy Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editPregnancy,
                icon: const FaIcon(FontAwesomeIcons.pen, size: 14),
                label: const Text('Hamilelik Bilgisini Düzenle'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryPurple,
                  side: const BorderSide(color: AppColors.primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 16, color: iconColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePregnancyCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryPink.withValues(alpha: 0.3),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryPink.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.baby,
                size: 28,
                color: AppColors.primaryPink,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Hamilelik Bilgisi Ekleyin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hamilelik takibinizi başlatmak için bilgilerinizi girin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: _editPregnancy,
              icon: const FaIcon(FontAwesomeIcons.plus, size: 16, color: Colors.white),
              label: const Text(
                'Hamilelik Bilgisi Ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
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
