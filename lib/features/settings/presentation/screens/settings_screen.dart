import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dorm/presentation/providers/dorm_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDormAsync = ref.watch(currentUserDormProvider);

    return Scaffold(
      backgroundColor: AppColors.cream50,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.h2.copyWith(color: AppColors.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button since it's a tab
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),

            // Dorm Settings Section
            _buildSectionHeader('Dorm Settings'),
            const SizedBox(height: AppSpacing.md),

            // Invite Code Card
            userDormAsync.when(
              data: (dorm) {
                if (dorm == null) return const SizedBox.shrink();
                return Column(
                  children: [
                    GlassCard(
                      type: GlassType.primary,
                      onTap: () => _copyInviteCode(context, dorm.inviteCode),
                      child: _buildInviteCodeTile(dorm.inviteCode),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                // TODO: Navigate to dorm information
                _showComingSoon(context, 'Dorm Information');
              },
              child: _buildSettingsTile(
                icon: Icons.home,
                title: 'Dorm Information',
                subtitle: 'View and manage dorm details',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                // TODO: Navigate to member management
                _showComingSoon(context, 'Member Management');
              },
              child: _buildSettingsTile(
                icon: Icons.people,
                title: 'Manage Members',
                subtitle: 'View and manage dorm members',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              type: GlassType.error,
              onTap: () {
                _showLeaveDormDialog(context, ref);
              },
              child: _buildSettingsTile(
                icon: Icons.exit_to_app,
                title: 'Leave Dorm',
                subtitle: 'Leave current dorm',
                isDestructive: true,
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // App Settings Section
            _buildSectionHeader('App Settings'),
            const SizedBox(height: AppSpacing.md),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                _showComingSoon(context, 'Notifications');
              },
              child: _buildSettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Manage notification preferences',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                _showComingSoon(context, 'Privacy & Security');
              },
              child: _buildSettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy & Security',
                subtitle: 'Manage privacy settings',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                _showComingSoon(context, 'Help & Support');
              },
              child: _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            GlassCard(
              type: GlassType.primary,
              onTap: () {
                _showAboutDialog(context);
              },
              child: _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About Casaly',
                subtitle: 'App version and information',
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: AppSpacing.md),

            GlassCard(
              type: GlassType.error,
              onTap: () {
                _showSignOutDialog(context, ref);
              },
              child: _buildSettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                isDestructive: true,
              ),
            ),

            // Bottom padding for floating nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCodeTile(String inviteCode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.green400.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.qr_code, color: AppColors.green400, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Code',
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.cream800,
                ),
              ),
              Text(
                inviteCode,
                style: AppTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.green400,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.copy, size: 20, color: AppColors.cream400),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: AppTypography.h3.copyWith(
          color: AppColors.green400,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.green400;
    final textColor = isDestructive ? AppColors.error : AppColors.cream800;
    final subtitleColor = isDestructive
        ? AppColors.error.withOpacity(0.7)
        : AppColors.cream600;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySm.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.cream400),
      ],
    );
  }

  void _copyInviteCode(BuildContext context, String inviteCode) async {
    try {
      await Clipboard.setData(ClipboardData(text: inviteCode));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.green400,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Invite code copied to clipboard!',
                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Failed to copy invite code',
              style: AppTypography.bodyMd.copyWith(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.green400,
      ),
    );
  }

  void _showLeaveDormDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Dorm',
          style: AppTypography.h3.copyWith(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to leave this dorm? You\'ll need an invite code to rejoin.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement leave dorm functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Leave dorm functionality not implemented yet'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Leave',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authRepositoryProvider).signOut();
            },
            child: Text(
              'Sign Out',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Casaly',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.home,
        size: 48,
        color: AppColors.green400,
      ),
      children: [
        Text('Shared living made simple', style: AppTypography.bodyMd),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Casaly helps you manage your shared living space with features for cleaning schedules, laundry management, and dorm coordination.',
          style: AppTypography.bodySm.copyWith(color: AppColors.cream600),
        ),
      ],
    );
  }
}
