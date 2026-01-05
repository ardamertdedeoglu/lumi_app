import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../services/app_state.dart';
import '../../widgets/profile/settings_menu_item.dart';
import '../../widgets/shared/section_header.dart';
import 'edit_profile_screen.dart';
import 'edit_pregnancy_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const ProfileScreen({super.key, this.onLogout});

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

  String? _pairingCode;
  bool _isGeneratingCode = false;
  bool _isLinkingPartner = false;

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

          // AppState'i de güncelle - diğer ekranlar da güncellensin
          final appState = Provider.of<AppState>(context, listen: false);
          appState.updateProfile(result.data!.profile);
          if (result.data!.pregnancy != null) {
            appState.updatePregnancy(result.data!.pregnancy);
          }
        } else {
          _errorMessage = result.errorMessage;
        }
      });
    }
  }

  /// Profil ve AppState'i birlikte yenile
  Future<void> _refreshAll() async {
    await _loadProfile();
    if (mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.refreshProfile();
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
    // Dialog göstermeden önce onLogout callback'ini kaydet
    final onLogoutCallback = widget.onLogout;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // Dialog'un kendi context'inden theme al
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
        final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A2E);
        final textSecondary = isDark
            ? const Color(0xFFB0B0C0)
            : const Color(0xFF4A4A5A);
        final textTertiary = isDark
            ? const Color(0xFF808090)
            : const Color(0xFF6A6A7A);

        return AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    size: 18,
                    color: AppColors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Çıkış Yap',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Hesabınızdan çıkış yapmak istediğinize emin misiniz? Tekrar giriş yapmanız gerekecek.',
            style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && onLogoutCallback != null) {
      // Önce auth service'den çıkış yap
      await _authService.logout();
      // Sonra callback'i çağır - bu noktada context kullanmıyoruz
      onLogoutCallback();
    }
  }

  void _editProfile() {
    if (_fullProfile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          profile: _fullProfile!.profile,
          onSaved: _refreshAll,
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
          onSaved: _refreshAll,
        ),
      ),
    );
  }

  Future<void> _generateCode() async {
    setState(() => _isGeneratingCode = true);
    final result = await _profileService.generateFamilyCode();
    setState(() {
      _isGeneratingCode = false;
      if (result.isSuccess) {
        _pairingCode = result.data;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Kod oluşturulamadı')),
        );
      }
    });
  }

  Future<void> _showLinkPartnerDialog() async {
    final codeController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Eşleşme Kodu Girin',
          style: TextStyle(color: context.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partnerinizin oluşturduğu 6 haneli kodu buraya girin.',
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                hintText: '000000',
                filled: true,
                fillColor: context.colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(color: context.colors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Eşleş', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && codeController.text.isNotEmpty) {
      setState(() => _isLinkingPartner = true);
      final result = await _profileService.linkPartner(codeController.text);
      setState(() => _isLinkingPartner = false);
      if (result.isSuccess) {
        _refreshAll();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Eşleşme başarılı!')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage ?? 'Eşleşme başarısız')),
          );
        }
      }
    }
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
            const CircularProgressIndicator(color: AppColors.primaryPink),
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
                  minimumSize: const Size(200, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _logout,
                icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 16),
                label: const Text('Çıkış Yap'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  minimumSize: const Size(200, 45),
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
      onRefresh: _refreshAll,
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

            // Pregnancy Info Card veya Bilgilendirme
            if (pregnancy != null)
              _buildPregnancyInfoCard(
                context,
                pregnancy,
                dateFormat,
                profile.isFather,
              )
            else if (profile.isMother)
              _buildCreatePregnancyCard(context)
            else
              _buildFatherNoPregnancyCard(context),

            const SizedBox(height: 28),

            // Section: Family Pairing
            const SectionHeader(title: 'Aile Eşleşmesi'),

            const SizedBox(height: 16),

            _buildFamilyPairingCard(context, profile),

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
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfileData profile,
    PregnancyData? pregnancy,
  ) {
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
              Text(
                profile.isFather ? '👨‍💼' : '🤰',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            profile.isFather ? 'Baba Hesabı' : 'Anne Hesabı',
            style: TextStyle(
              fontSize: 13,
              color: colors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
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
                style: TextStyle(fontSize: 14, color: colors.textTertiary),
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

  Widget _buildPregnancyInfoCard(
    BuildContext context,
    PregnancyData pregnancy,
    DateFormat dateFormat,
    bool isFather,
  ) {
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
          if (pregnancy.doctorName != null &&
              pregnancy.doctorName!.isNotEmpty) ...[
            Divider(color: colors.border, height: 1, indent: 70),
            _buildPregnancyInfoItem(
              context,
              icon: FontAwesomeIcons.userDoctor,
              label: AppStrings.doctor,
              value: pregnancy.doctorName!,
              iconColor: AppColors.primaryBlue,
            ),
          ],
          // Edit Pregnancy Button - Sadece anneler için
          if (!isFather)
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

  Widget _buildFamilyPairingCard(
    BuildContext context,
    UserProfileData profile,
  ) {
    final colors = context.colors;

    if (profile.hasPartner) {
      final partnerName = profile.partnerInfo?['full_name'] ?? 'Partner';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.userGroup,
                  size: 20,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hesabınız partnerinizle eşleşti',
                    style: TextStyle(fontSize: 13, color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.checkCircle,
              color: AppColors.green,
              size: 20,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          Text(
            profile.isMother
                ? 'Partnerinizi (Baba) hesabınıza bağlayın.'
                : 'Partnerinizin (Anne) hesabına bağlanın.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (profile.isMother) ...[
            if (_pairingCode == null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingCode ? null : _generateCode,
                  icon: _isGeneratingCode
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const FaIcon(FontAwesomeIcons.key, size: 16),
                  label: const Text('Eşleşme Kodu Oluştur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryPink.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Eşleşme Kodunuz',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _pairingCode!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bu kod 15 dakika geçerlidir.',
                    style: TextStyle(fontSize: 12, color: colors.textTertiary),
                  ),
                  TextButton(
                    onPressed: _generateCode,
                    child: const Text('Yeni Kod Oluştur'),
                  ),
                ],
              ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLinkingPartner ? null : _showLinkPartnerDialog,
                icon: _isLinkingPartner
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const FaIcon(FontAwesomeIcons.link, size: 16),
                label: const Text('Kodu Gir ve Bağlan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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
            child: Center(child: FaIcon(icon, size: 16, color: iconColor)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13, color: colors.textTertiary),
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

  Widget _buildFatherNoPregnancyCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.userGroup,
                size: 28,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz Bilgi Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bebeğinizin gelişimini takip etmek için partnerinizin (Anne) hesabıyla eşleşme yapın.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colors.textTertiary),
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
            style: TextStyle(fontSize: 14, color: colors.textTertiary),
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
              icon: const FaIcon(
                FontAwesomeIcons.plus,
                size: 16,
                color: Colors.white,
              ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
              style: TextStyle(fontSize: 13, color: colors.textMuted),
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
