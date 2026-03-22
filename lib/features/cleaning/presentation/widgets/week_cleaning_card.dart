import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../dorm/domain/entities/dorm_member.dart';
import '../../domain/entities/cleaning_assignment.dart';

class WeekCleaningCard extends StatelessWidget {
  final CleaningAssignment? assignment;
  final List<DormMember> groupMembers;
  final String groupName;
  final int daysUntilNext;
  final String? nextGroupName;
  final VoidCallback? onTap;

  const WeekCleaningCard({
    super.key,
    this.assignment,
    required this.groupMembers,
    required this.groupName,
    this.daysUntilNext = 0,
    this.nextGroupName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with member avatars on left
            Row(
              children: [
                // Member avatars (overlapping)
                _buildMemberAvatars(),

                const Spacer(),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Week rotation text
            Text(
              "This Week's Rotation",
              style: AppTypography.labelMd.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            // Group name
            Text(
              "$groupName's turn",
              style: AppTypography.headlineSm.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Next rotation info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getNextRotationText(),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    _getDaysText(),
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberAvatars() {
    if (groupMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show up to 3 avatars, overlapping
    final visibleMembers = groupMembers.take(3).toList();
    const avatarSize = 36.0;
    const overlapOffset = 24.0;

    // Calculate total visual elements (avatars + potential "+X more" indicator)
    final totalElements = groupMembers.length > 3 ? 4 : visibleMembers.length;
    
    return SizedBox(
      width: totalElements == 1
          ? avatarSize
          : ((totalElements - 1) * overlapOffset) + avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          for (int i = 0; i < visibleMembers.length; i++)
            Positioned(
              left: i * overlapOffset,
              child: UserAvatar(
                displayName: visibleMembers[i].displayName,
                profileImageUrl: visibleMembers[i].profileImageUrl,
                size: avatarSize,
                showBorder: true,
                borderColor: AppColors.onPrimary,
              ),
            ),

          // Show "+X more" indicator if there are more than 3 members
          if (groupMembers.length > 3)
            Positioned(
              left: 3 * overlapOffset, // Position after 3 avatars
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.onPrimary, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+${groupMembers.length - 3}',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getNextRotationText() {
    if (nextGroupName != null && nextGroupName!.isNotEmpty) {
      return 'Next: $nextGroupName';
    }
    return 'Next: TBD';
  }

  String _getDaysText() {
    if (daysUntilNext == 0) {
      return 'Today';
    } else if (daysUntilNext == 1) {
      return 'Tomorrow';
    } else {
      return 'In $daysUntilNext Days';
    }
  }
}
