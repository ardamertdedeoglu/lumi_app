import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';

class HeaderWidget extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onProfileTap;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const HeaderWidget({
    super.key,
    required this.user,
    this.onProfileTap,
    this.onThemeToggle,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tekrar merhaba,',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '🤰',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),

          // Theme Toggle & Profile
          Row(
            children: [
              // Theme Toggle Button
              GestureDetector(
                onTap: onThemeToggle,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: FaIcon(
                        isDarkMode
                            ? FontAwesomeIcons.sun
                            : FontAwesomeIcons.moon,
                        key: ValueKey(isDarkMode),
                        size: 16,
                        color: isDarkMode
                            ? AppColors.primaryPink
                            : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Profile Picture
              GestureDetector(
                onTap: onProfileTap,
                child: Stack(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: colors.borderLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.user,
                          size: 20,
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                    if (user.hasNotification)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.background,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
