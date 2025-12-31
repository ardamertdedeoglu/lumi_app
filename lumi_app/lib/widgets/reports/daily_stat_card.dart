import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DailyStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String? subtitle;
  final Color iconBackgroundColor;
  final Color iconColor;
  final double? progress;

  const DailyStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.subtitle,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
              ),
              const Spacer(),
              if (progress != null)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: colors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                      Center(
                        child: Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DailyStatsRow extends StatelessWidget {
  final List<DailyStatCard> cards;

  const DailyStatsRow({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: cards
            .map((card) => Expanded(child: card))
            .expand((widget) => [widget, const SizedBox(width: 15)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
