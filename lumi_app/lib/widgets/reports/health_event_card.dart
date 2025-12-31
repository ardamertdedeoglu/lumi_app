import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/health_report_model.dart';

class HealthEventCard extends StatelessWidget {
  final HealthEvent event;

  const HealthEventCard({
    super.key,
    required this.event,
  });

  IconData get _icon {
    switch (event.type) {
      case HealthEventType.doctorVisit:
        return FontAwesomeIcons.userDoctor;
      case HealthEventType.labResult:
        return FontAwesomeIcons.flask;
      case HealthEventType.note:
        return FontAwesomeIcons.noteSticky;
      case HealthEventType.ultrasound:
        return FontAwesomeIcons.baby;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dateFormat = DateFormat('dd MMM', 'tr_TR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          left: BorderSide(
            color: event.accentColor,
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: event.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                _icon,
                size: 18,
                color: event.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            dateFormat.format(event.date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthEventsList extends StatelessWidget {
  final List<HealthEvent> events;

  const HealthEventsList({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: events.map((event) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HealthEventCard(event: event),
          );
        }).toList(),
      ),
    );
  }
}
