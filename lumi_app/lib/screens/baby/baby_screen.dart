import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/baby_development_model.dart';
import '../../services/app_state.dart';
import '../../widgets/baby/baby_size_card.dart';
import '../../widgets/baby/development_info_card.dart';
import '../../widgets/baby/milestone_item.dart';
import '../../widgets/baby/tips_card.dart';
import '../../widgets/shared/section_header.dart';

class BabyScreen extends StatelessWidget {
  const BabyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Yükleniyor durumu - sadece ilk yüklemede göster
        if (appState.isLoading && !appState.isInitialized) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryPink),
                const SizedBox(height: 16),
                Text(
                  'Bebek bilgileri yükleniyor...',
                  style: TextStyle(color: colors.textTertiary),
                ),
              ],
            ),
          );
        }

        final pregnancy = appState.pregnancy;

        // Eğer hamilelik bilgisi yoksa bilgilendirme göster
        if (pregnancy == null) {
          return _buildNoPregnancyState(context);
        }

        // Hamilelik haftasına göre bebek gelişim verisini al
        final currentWeek = pregnancy.currentWeek;
        final development = BabyDevelopmentModel.getForWeek(currentWeek);

        return RefreshIndicator(
          onRefresh: () => appState.refreshProfile(),
          color: AppColors.primaryPink,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Page Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.yourBabyThisWeek,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$currentWeek. Hafta',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Baby Size Card
                BabySizeCard(development: development),

                const SizedBox(height: 28),

                // Section: Physical Development
                const SectionHeader(title: AppStrings.physicalDevelopment),

                const SizedBox(height: 16),

                // Development Info Grid
                DevelopmentInfoGrid(
                  cards: [
                    DevelopmentInfoCard(
                      icon: FontAwesomeIcons.rulerVertical,
                      label: AppStrings.length,
                      value: development.length,
                      iconBackgroundColor: colors.purpleLight,
                      iconColor: AppColors.primaryPurple,
                    ),
                    DevelopmentInfoCard(
                      icon: FontAwesomeIcons.weightScale,
                      label: AppStrings.weight,
                      value: development.weight,
                      iconBackgroundColor: colors.pinkLight,
                      iconColor: AppColors.primaryPink,
                    ),
                    DevelopmentInfoCard(
                      icon: FontAwesomeIcons.heartPulse,
                      label: AppStrings.heartRate,
                      value: development.heartRate,
                      iconBackgroundColor: colors.redLight,
                      iconColor: AppColors.red,
                    ),
                    DevelopmentInfoCard(
                      icon: FontAwesomeIcons.personRunning,
                      label: AppStrings.movements,
                      value: development.movements,
                      iconBackgroundColor: colors.blueLight,
                      iconColor: AppColors.primaryBlue,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Section: This Week's Milestones
                const SectionHeader(title: AppStrings.thisWeekMilestones),

                const SizedBox(height: 16),

                // Milestones List
                MilestonesList(milestones: development.milestones),

                const SizedBox(height: 28),

                // Section: Tips for Mom/Dad
                SectionHeader(
                  title: appState.profile?.isFather == true 
                      ? AppStrings.tipsForDad 
                      : AppStrings.tipsForMom
                ),

                const SizedBox(height: 16),

                // Tips Card
                TipsCard(
                  tips: appState.profile?.isFather == true 
                      ? development.fatherTips 
                      : development.tips
                ),

                const SizedBox(height: 28),

                // Progress Indicator
                _buildPregnancyProgress(context, currentWeek),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoPregnancyState(BuildContext context) {
    final colors = context.colors;
    final appState = Provider.of<AppState>(context, listen: false);
    final isFather = appState.profile?.isFather ?? false;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: (isFather ? AppColors.primaryBlue : AppColors.primaryPink)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FaIcon(
                  isFather ? FontAwesomeIcons.userGroup : FontAwesomeIcons.baby,
                  size: 48,
                  color: isFather ? AppColors.primaryBlue : AppColors.primaryPink,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bebek Gelişimi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFather
                  ? 'Bebeğinizin haftalık gelişimini takip etmek için partnerinizin (Anne) hesabıyla eşleşme yapın.'
                  : 'Bebeğinizin haftalık gelişimini takip etmek için profilinizden hamilelik bilgilerinizi girin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colors.textTertiary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: isFather ? AppColors.blueGradient : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Profil sayfasına yönlendir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFather
                            ? 'Profil sekmesinden eşleşme yapabilirsiniz'
                            : 'Profil sekmesinden hamilelik bilgilerinizi girebilirsiniz',
                      ),
                      backgroundColor: colors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.arrowRight,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Profil\'e Git',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyProgress(BuildContext context, int currentWeek) {
    final colors = context.colors;
    final progress = currentWeek / 40; // 40 hafta toplam
    final trimester = _getTrimester(currentWeek);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gebelik İlerlemesi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getTrimesterColor(trimester).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$trimester. Trimester',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getTrimesterColor(trimester),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: colors.surface,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryPink,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentWeek / 40 Hafta',
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
              Text(
                '%${(progress * 100).toInt()} tamamlandı',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Trimester Labels
          Row(
            children: [
              _buildTrimesterLabel(context, 1, currentWeek),
              const SizedBox(width: 8),
              _buildTrimesterLabel(context, 2, currentWeek),
              const SizedBox(width: 8),
              _buildTrimesterLabel(context, 3, currentWeek),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterLabel(
    BuildContext context,
    int trimester,
    int currentWeek,
  ) {
    final colors = context.colors;
    final currentTrimester = _getTrimester(currentWeek);
    final isActive = trimester == currentTrimester;
    final isPast = trimester < currentTrimester;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? _getTrimesterColor(trimester).withValues(alpha: 0.1)
              : isPast
              ? AppColors.green.withValues(alpha: 0.1)
              : colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(color: _getTrimesterColor(trimester), width: 1)
              : null,
        ),
        child: Column(
          children: [
            if (isPast)
              const FaIcon(
                FontAwesomeIcons.check,
                size: 12,
                color: AppColors.green,
              )
            else
              Text(
                '$trimester',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? _getTrimesterColor(trimester)
                      : colors.textTertiary,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              _getTrimesterLabel(trimester),
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? _getTrimesterColor(trimester)
                    : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getTrimester(int week) {
    if (week <= 13) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  Color _getTrimesterColor(int trimester) {
    switch (trimester) {
      case 1:
        return AppColors.primaryPink;
      case 2:
        return AppColors.primaryPurple;
      case 3:
        return AppColors.primaryBlue;
      default:
        return AppColors.primaryPink;
    }
  }

  String _getTrimesterLabel(int trimester) {
    switch (trimester) {
      case 1:
        return '1-13 Hafta';
      case 2:
        return '14-27 Hafta';
      case 3:
        return '28-40 Hafta';
      default:
        return '';
    }
  }
}
