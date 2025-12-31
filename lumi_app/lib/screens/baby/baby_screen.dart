import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/baby_development_model.dart';
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
    final development = BabyDevelopmentModel.demo;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Page Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.yourBabyThisWeek,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
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

          // Section: Tips for Mom
          const SectionHeader(title: AppStrings.tipsForMom),

          const SizedBox(height: 16),

          // Tips Card
          TipsCard(tips: development.tips),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
