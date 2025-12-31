import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/app_strings.dart';
import '../../models/user_model.dart';
import '../../models/pregnancy_model.dart';
import '../../models/task_model.dart';
import '../../widgets/home/header_widget.dart';
import '../../widgets/home/ai_insight_card.dart';
import '../../widgets/home/status_card.dart';
import '../../widgets/home/quick_action_button.dart';
import '../../widgets/home/task_card.dart';
import '../../widgets/shared/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Demo data - in real app, this would come from a provider/service
  final UserModel user = UserModel.demo;
  final PregnancyModel pregnancy = PregnancyModel.demo;
  late List<TaskModel> tasks;

  @override
  void initState() {
    super.initState();
    tasks = List.from(TaskModel.demoTasks);
  }

  void _toggleTask(TaskModel task) {
    setState(() {
      final index = tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = context.colors;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Header with Theme Toggle
          HeaderWidget(
            user: user,
            isDarkMode: themeProvider.isDarkMode,
            onThemeToggle: () {
              themeProvider.toggleTheme();
            },
            onProfileTap: () {
              // Navigate to profile
            },
          ),

          const SizedBox(height: 24),

          // AI Insight Card
          AIInsightCard(
            badgeText: AppStrings.babyDevelopment,
            message: pregnancy.aiInsightMessage,
            icon: FontAwesomeIcons.baby,
          ),

          const SizedBox(height: 24),

          // Section: Pregnancy Status
          const SectionHeader(
            title: AppStrings.pregnancyStatus,
            actionText: AppStrings.calendar,
          ),

          const SizedBox(height: 16),

          // Status Cards Grid
          StatusCardsGrid(
            cards: [
              StatusCard(
                icon: FontAwesomeIcons.calendarCheck,
                iconBackgroundColor: colors.pinkLight,
                iconColor: AppColors.primaryPink,
                value: pregnancy.weekLabel,
                label: AppStrings.pregnancyWeek,
              ),
              StatusCard(
                icon: FontAwesomeIcons.hourglassHalf,
                iconBackgroundColor: colors.purpleLight,
                iconColor: AppColors.primaryPurple,
                value: pregnancy.daysLabel,
                label: AppStrings.daysUntilBirth,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Quick Actions
          const SectionHeader(
            title: AppStrings.quickActions,
          ),

          const SizedBox(height: 16),

          // Quick Actions Row
          QuickActionsRow(
            actions: [
              QuickActionButton(
                icon: FontAwesomeIcons.shoePrints,
                label: AppStrings.kick,
                iconBackgroundColor: colors.redLight,
                iconColor: AppColors.red,
                onTap: () {
                  // Log kick
                },
              ),
              QuickActionButton(
                icon: FontAwesomeIcons.weightScale,
                label: AppStrings.addWeight,
                iconBackgroundColor: colors.greenLight,
                iconColor: AppColors.green,
                onTap: () {
                  // Add weight
                },
              ),
              QuickActionButton(
                icon: FontAwesomeIcons.glassWater,
                label: AppStrings.waterTracking,
                iconBackgroundColor: colors.blueLight,
                iconColor: AppColors.primaryBlue,
                onTap: () {
                  // Track water
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Today's Plan
          const SectionHeader(
            title: AppStrings.todaysPlan,
          ),

          const SizedBox(height: 16),

          // Tasks List
          TasksList(
            tasks: tasks,
            onTaskCheckTap: _toggleTask,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
