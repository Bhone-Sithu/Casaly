import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';
import 'user_avatar.dart';

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String userDisplayName;
  final String? userProfileImageUrl;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAvatarTap;
  final int notificationCount;
  final bool isScrolled;

  const TopNavigationBar({
    super.key,
    required this.userDisplayName,
    this.userProfileImageUrl,
    this.onNotificationTap,
    this.onAvatarTap,
    this.notificationCount = 0,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isScrolled ? Colors.transparent : AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 50,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isScrolled ? 10.0 : 0.0,
            sigmaY: isScrolled ? 10.0 : 0.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isScrolled 
                  ? AppColors.surface.withValues(alpha: 0.8)
                  : AppColors.surface,
              border: isScrolled 
                  ? Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    // User Avatar
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: UserAvatar(
                        displayName: userDisplayName,
                        profileImageUrl: userProfileImageUrl,
                        size: 38,
                        showBorder: true,
                      ),
                    ),

                    const SizedBox(width: AppSpacing.lg),

                    // Casaly Logo Text
                    Expanded(
                      child: Text(
                        'Casaly',
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    // Notification Button
                    Stack(
                      children: [
                        IconButton(
                          onPressed: onNotificationTap,
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.onSurface,
                            size: 20,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            shape: const CircleBorder(),
                          ),
                        ),
                        if (notificationCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surface,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  notificationCount > 9
                                      ? '9+'
                                      : notificationCount.toString(),
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onTertiary,
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
