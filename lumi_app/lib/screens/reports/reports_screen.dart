import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/health_report_model.dart';
import '../../widgets/reports/weight_chart_card.dart';
import '../../widgets/reports/daily_stat_card.dart';
import '../../widgets/reports/health_event_card.dart';
import '../../widgets/shared/section_header.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final report = HealthReportModel.demo;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Page Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.reportsScreenTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Weight Tracking
          const SectionHeader(title: AppStrings.weightTracking),

          const SizedBox(height: 16),

          // Weight Chart Card
          WeightChartCard(
            weightHistory: report.weightHistory,
            currentWeight: report.currentWeight,
            totalGain: report.totalWeightGain,
          ),

          const SizedBox(height: 28),

          // Section: Daily Tracking
          const SectionHeader(title: AppStrings.dailyTracking),

          const SizedBox(height: 16),

          // Daily Stats Row
          DailyStatsRow(
            cards: [
              DailyStatCard(
                icon: FontAwesomeIcons.glassWater,
                label: AppStrings.waterIntake,
                value: report.todayWaterGlasses.toString(),
                unit: '/ ${report.waterGoal} ${AppStrings.glasses}',
                subtitle: AppStrings.today,
                iconBackgroundColor: colors.blueLight,
                iconColor: AppColors.primaryBlue,
                progress: report.todayWaterGlasses / report.waterGoal,
              ),
              DailyStatCard(
                icon: FontAwesomeIcons.shoePrints,
                label: AppStrings.kickCount,
                value: report.todayKickCount.toString(),
                unit: AppStrings.kicks,
                subtitle: AppStrings.today,
                iconBackgroundColor: colors.pinkLight,
                iconColor: AppColors.primaryPink,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Section: Health History
          SectionHeader(
            title: AppStrings.healthHistory,
            actionText: AppStrings.viewAll,
            onActionTap: () {
              // Show all health events
            },
          ),

          const SizedBox(height: 16),

          // Health Events List
          HealthEventsList(events: report.healthEvents),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
