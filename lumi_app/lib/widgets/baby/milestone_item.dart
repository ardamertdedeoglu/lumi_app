import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';

class MilestoneItem extends StatelessWidget {
  final String text;
  final Color? accentColor;

  const MilestoneItem({
    super.key,
    required this.text,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = accentColor ?? AppColors.primaryPurple;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.check,
                size: 14,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MilestonesList extends StatelessWidget {
  final List<String> milestones;

  const MilestonesList({
    super.key,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    final accentColors = [
      AppColors.primaryPurple,
      AppColors.primaryPink,
      AppColors.primaryBlue,
      AppColors.green,
      AppColors.primaryPurple,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: milestones.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MilestoneItem(
              text: entry.value,
              accentColor: accentColors[entry.key % accentColors.length],
            ),
          );
        }).toList(),
      ),
    );
  }
}
