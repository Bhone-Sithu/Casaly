import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const ChatInput({super.key, required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.md,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              enableSuggestions: true,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              style: AppTypography.bodyMd,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  onSend(text);
                }
              },
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Send button
          GestureDetector(
            onTap: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                onSend(text);
              }
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send,
                color: AppColors.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
