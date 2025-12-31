import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';

enum SettingsItemType {
  navigation,
  toggle,
  info,
}

class SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final SettingsItemType type;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.iconColor,
    this.type = SettingsItemType.navigation,
    this.toggleValue,
    this.onToggleChanged,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        InkWell(
          onTap: type == SettingsItemType.toggle ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(
                      icon,
                      size: 16,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildTrailing(context),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            color: colors.border,
            height: 1,
            indent: 70,
          ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final colors = context.colors;

    switch (type) {
      case SettingsItemType.navigation:
        return FaIcon(
          FontAwesomeIcons.chevronRight,
          size: 14,
          color: colors.textMuted,
        );
      case SettingsItemType.toggle:
        return Switch(
          value: toggleValue ?? false,
          onChanged: onToggleChanged,
          activeColor: AppColors.primaryPink,
        );
      case SettingsItemType.info:
        return const SizedBox.shrink();
    }
  }
}

class SettingsMenuCard extends StatelessWidget {
  final List<SettingsMenuItem> items;

  const SettingsMenuCard({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
          final isLast = entry.key == items.length - 1;
          return SettingsMenuItem(
            icon: entry.value.icon,
            title: entry.value.title,
            subtitle: entry.value.subtitle,
            iconColor: entry.value.iconColor,
            type: entry.value.type,
            toggleValue: entry.value.toggleValue,
            onToggleChanged: entry.value.onToggleChanged,
            onTap: entry.value.onTap,
            showDivider: !isLast,
          );
        }).toList(),
      ),
    );
  }
}
