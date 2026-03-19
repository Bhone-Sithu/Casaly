import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/user_profile_providers.dart';
import 'user_avatar.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Drawer(
      backgroundColor: AppColors.cream50,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.green50,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.green200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.green400,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.green400,
                    ),
                  ),
                ],
              ),
            ),

            // User Profile Section
            userProfileAsync.when(
              data: (userProfile) {
                if (userProfile == null) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Text(
                          'Profile not found',
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Card(
                    color: Colors.white,
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.push('/profile');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            UserAvatar(
                              userProfile: userProfile,
                              size: 60,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userProfile.displayNameOrEmail,
                                    style: AppTypography.h3.copyWith(
                                      color: AppColors.green400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    userProfile.email,
                                    style: AppTypography.bodyMd.copyWith(
                                      color: AppColors.cream600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'View Profile',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.green400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.cream400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: AppSpacing.md),
                        Text('Loading profile...'),
                      ],
                    ),
                  ),
                ),
              ),
              error: (error, stack) => Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Error loading profile',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Settings Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Dorm Settings Section
                  _buildSectionHeader('Dorm Settings'),
                  _buildSettingsTile(
                    icon: Icons.home,
                    title: 'Dorm Information',
                    subtitle: 'View and manage dorm details',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to dorm settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dorm settings not implemented yet'),
                          backgroundColor: AppColors.green400,
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.people,
                    title: 'Manage Members',
                    subtitle: 'View and manage dorm members',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to member management
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Member management not implemented yet'),
                          backgroundColor: AppColors.green400,
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.exit_to_app,
                    title: 'Leave Dorm',
                    subtitle: 'Leave current dorm',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Show leave dorm dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Leave dorm functionality not implemented yet'),
                          backgroundColor: AppColors.orange400,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // App Settings Section
                  _buildSectionHeader('App Settings'),
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to notification settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification settings not implemented yet'),
                          backgroundColor: AppColors.green400,
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy & Security',
                    subtitle: 'Manage privacy settings',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to privacy settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings not implemented yet'),
                          backgroundColor: AppColors.green400,
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to help
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & support not implemented yet'),
                          backgroundColor: AppColors.green400,
                        ),
                      );
                    },
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline,
                    title: 'About Casaly',
                    subtitle: 'App version and information',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            // Sign Out Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.cream200,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                ),
                title: Text(
                  'Sign Out',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.error,
                  ),
                ),
                onTap: () => _showSignOutDialog(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTypography.labelMd.copyWith(
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.green400,
        ),
        title: Text(
          title,
          style: AppTypography.bodyLg,
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.cream600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.cream400,
        ),
        onTap: onTap,
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
              Navigator.of(context).pop(); // Close drawer
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
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
        Text(
          'Shared living made simple',
          style: AppTypography.bodyMd,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Casaly helps you manage your shared living space with features for cleaning schedules, laundry management, and dorm coordination.',
          style: AppTypography.bodySm.copyWith(
            color: AppColors.cream600,
          ),
        ),
      ],
    );
  }
}