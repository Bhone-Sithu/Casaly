import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isCurrentUser ? 50 : 0,
          right: isCurrentUser ? 0 : 50,
        ),
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Sender name (only for other users)
            if (!isCurrentUser)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  message.senderName,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Message content
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    message.content,
                    style: AppTypography.bodyMd.copyWith(
                      color: isCurrentUser
                          ? AppColors.onPrimary
                          : AppColors.onSurface,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: AppTypography.labelSm.copyWith(
                          color: isCurrentUser
                              ? AppColors.onPrimary.withValues(alpha: 0.8)
                              : AppColors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),

                      // Read indicator for current user's messages
                      if (isCurrentUser) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color: isCurrentUser
                              ? (message.isRead
                                    ? AppColors.onPrimary
                                    : AppColors.onPrimary.withValues(
                                        alpha: 0.7,
                                      ))
                              : AppColors.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day, show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Within a week, show day name
      const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return dayNames[dateTime.weekday % 7];
    } else {
      // Show date
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
