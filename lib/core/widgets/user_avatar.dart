import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class UserAvatar extends StatelessWidget {
  final String displayName;
  final String? profileImageUrl;
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const UserAvatar({
    super.key,
    required this.displayName,
    this.profileImageUrl,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(color: borderColor ?? AppColors.outlineVariant, width: 2)
              : null,
          image: DecorationImage(
            image: NetworkImage(profileImageUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Generate default avatar with initials and themed background
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getBackgroundColor(displayName),
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.outlineVariant, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          _getInitials(displayName),
          style: AppTypography.labelMd.copyWith(
            color: Colors.white,
            fontSize: size * 0.4, // Scale font size with avatar size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0]}${words.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getBackgroundColor(String name) {
    // Generate consistent color based on name hash
    final hash = name.hashCode;
    final colorIndex = hash.abs() % _avatarColors.length;
    return _avatarColors[colorIndex];
  }

  // Themed avatar background colors from our design system
  static const List<Color> _avatarColors = [
    AppColors.primary, // Deep forest green
    AppColors.secondary, // Sunset orange
    AppColors.tertiary, // Deep berry
    AppColors.primaryFixedDim, // Dimmed green
    AppColors.secondaryFixedDim, // Active orange
    Color(0xFF6B4E3D), // Warm brown
    Color(0xFF4A5D6B), // Slate blue
    Color(0xFF6B4A6B), // Plum
    Color(0xFF4A6B5D), // Forest teal
    Color(0xFF6B5D4A), // Copper
  ];
}
