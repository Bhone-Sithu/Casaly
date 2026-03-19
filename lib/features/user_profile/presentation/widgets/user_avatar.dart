import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/user_profile.dart';

class UserAvatar extends StatelessWidget {
  final UserProfile? userProfile;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const UserAvatar({
    required this.userProfile,
    this.size = 40,
    this.showBorder = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = _buildAvatar();
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }
    
    return avatar;
  }

  Widget _buildAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: AppColors.green400,
                width: 2,
              )
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: userProfile?.profileImageUrl != null
            ? Image.network(
                userProfile!.profileImageUrl!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
              )
            : _buildInitialsAvatar(),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.green400,
      ),
      child: Center(
        child: Text(
          userProfile?.initials ?? 'U',
          style: AppTypography.labelLg.copyWith(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}