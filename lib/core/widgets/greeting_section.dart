import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class GreetingSection extends StatelessWidget {
  final String userDisplayName;
  final String bodyText;

  const GreetingSection({
    super.key,
    required this.userDisplayName,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final firstName = _getFirstName(userDisplayName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large greeting text
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$greeting,\n',
                style: AppTypography.displayMd.copyWith(
                  color: AppColors.onSurface,
                  height: 1.1,
                ),
              ),
              TextSpan(
                text: '$firstName!',
                style: AppTypography.displayMd.copyWith(
                  color: AppColors.primary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Body text
        Text(
          bodyText,
          style: AppTypography.bodyLg.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  String _getFirstName(String fullName) {
    if (fullName.isEmpty) return 'User';

    final words = fullName.trim().split(' ');
    return words.first;
  }
}
