import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';

class PregnancyInfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const PregnancyInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });
}

class PregnancyInfoCard extends StatelessWidget {
  final DateTime lastPeriodDate;
  final DateTime expectedDueDate;
  final String doctorName;

  const PregnancyInfoCard({
    super.key,
    required this.lastPeriodDate,
    required this.expectedDueDate,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');

    final items = [
      PregnancyInfoItem(
        icon: FontAwesomeIcons.calendarDay,
        label: AppStrings.lastPeriodDate,
        value: dateFormat.format(lastPeriodDate),
        iconColor: AppColors.primaryPink,
      ),
      PregnancyInfoItem(
        icon: FontAwesomeIcons.baby,
        label: AppStrings.expectedDueDate,
        value: dateFormat.format(expectedDueDate),
        iconColor: AppColors.primaryPurple,
      ),
      PregnancyInfoItem(
        icon: FontAwesomeIcons.userDoctor,
        label: AppStrings.doctor,
        value: doctorName,
        iconColor: AppColors.primaryBlue,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: FaIcon(
                          item.icon,
                          size: 16,
                          color: item.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.value,
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
              ),
              if (!isLast)
                Divider(
                  color: colors.border,
                  height: 1,
                  indent: 70,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
