import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DevelopmentInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBackgroundColor;
  final Color iconColor;

  const DevelopmentInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBackgroundColor,
    required this.iconColor,
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class DevelopmentInfoGrid extends StatelessWidget {
  final List<DevelopmentInfoCard> cards;

  const DevelopmentInfoGrid({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
        children: cards,
      ),
    );
  }
}
