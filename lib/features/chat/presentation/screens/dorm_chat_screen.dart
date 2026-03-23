import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/top_navigation_bar.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../../domain/entities/message.dart';

class DormChatScreen extends ConsumerStatefulWidget {
  const DormChatScreen({super.key});

  @override
  ConsumerState<DormChatScreen> createState() => _DormChatScreenState();
}

class _DormChatScreenState extends ConsumerState<DormChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final isScrolled = _scrollController.offset > 10;
    if (_isScrolled != isScrolled) {
      setState(() {
        _isScrolled = isScrolled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = authState.value;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userDormAsync = ref.watch(userDormProvider(currentUser.uid));

    return userDormAsync.when(
      data: (dorm) {
        if (dorm == null) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            body: Center(
              child: Text(
                'Please join a dorm to access chat',
                style: AppTypography.bodyLg,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.surface,
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Main chat content
              Column(
                children: [
                  // Space for glass navigation bar
                  SizedBox(height: MediaQuery.of(context).padding.top + 60),
                  
                  // Messages list
                  Expanded(
                    child: _buildMessagesList(dorm.id, currentUser.uid),
                  ),
                  
                  // Chat input
                  ChatInput(
                    controller: _messageController,
                    onSend: (message) => _sendMessage(dorm.id, currentUser, message),
                  ),
                ],
              ),
              
              // Glass navigation bar positioned at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      height: MediaQuery.of(context).padding.top + 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.3),
                            AppColors.surface.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                        ),
                        child: TopNavigationBar(
                          userDisplayName: currentUser.displayName ?? currentUser.email,
                          userProfileImageUrl: null,
                          onNotificationTap: () {
                            // TODO: Navigate to notifications
                          },
                          onAvatarTap: () {
                            // TODO: Navigate to profile
                          },
                          notificationCount: 0,
                          isScrolled: _isScrolled,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Text(
            'Error: $error',
            style: AppTypography.bodyLg.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(String dormId, String currentUserId) {
    final messagesAsync = ref.watch(dormMessagesProvider(dormId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        // Mark messages as read when viewing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final markAsRead = ref.read(markMessagesAsReadProvider);
          markAsRead(dormId: dormId, userId: currentUserId);
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Start from bottom
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.senderId == currentUserId;
            
            // Show date separator if needed
            final showDateSeparator = index == messages.length - 1 ||
                !_isSameDay(message.timestamp, messages[index + 1].timestamp);

            return Column(
              children: [
                if (showDateSeparator) 
                  _buildDateSeparator(message.timestamp),
                MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error loading messages',
              style: AppTypography.bodyLg.copyWith(color: AppColors.error),
            ),
            Text(
              error.toString(),
              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No messages yet',
              style: AppTypography.h3.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start a conversation with your housemates!',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              _formatDate(date),
              style: AppTypography.labelSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.outline)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Future<void> _sendMessage(String dormId, dynamic currentUser, String content) async {
    if (content.trim().isEmpty) return;

    try {
      final sendMessage = ref.read(sendMessageProvider);
      await sendMessage(
        dormId: dormId,
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? currentUser.email ?? 'Unknown',
        content: content.trim(),
        type: MessageType.text,
      );

      _messageController.clear();
      
      // Scroll to bottom after sending message
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send message: ${e.toString()}',
              style: AppTypography.bodyMd.copyWith(color: AppColors.onTertiary),
            ),
            backgroundColor: AppColors.tertiary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    }
  }
}