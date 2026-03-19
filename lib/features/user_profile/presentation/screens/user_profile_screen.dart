import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/user_profile_providers.dart';
import '../widgets/user_avatar.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.h2.copyWith(
            color: AppColors.green400,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.green400, size: 28),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: Text(
                'Edit',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.green400,
                ),
              ),
            ),
        ],
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return const Center(
              child: Text('User profile not found'),
            );
          }

          // Initialize controllers when not editing
          if (!_isEditing) {
            _displayNameController.text = userProfile.displayName ?? '';
            _phoneController.text = userProfile.phoneNumber ?? '';
            _emailController.text = userProfile.email;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            UserAvatar(
                              userProfile: userProfile,
                              size: 120,
                              showBorder: true,
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _isUploadingImage ? null : _selectProfileImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _isUploadingImage ? AppColors.cream400 : AppColors.green400,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: _isUploadingImage
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          userProfile.displayNameOrEmail,
                          style: AppTypography.h2.copyWith(
                            color: AppColors.green400,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          userProfile.email,
                          style: AppTypography.bodyMd.copyWith(
                            color: AppColors.cream600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Form Fields
                  GlassCard(
                    type: GlassType.neutral,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.green400,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          
                          // Display Name Field
                          CasalyTextField(
                            controller: _displayNameController,
                            label: 'Display Name',
                            hint: 'Enter your display name',
                            enabled: _isEditing,
                            validator: (value) {
                              if (value?.trim().isEmpty ?? true) {
                                return 'Please enter a display name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Phone Field
                          CasalyTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: 'Enter your phone number',
                            keyboardType: TextInputType.phone,
                            enabled: _isEditing,
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Email Field (Read-only)
                          CasalyTextField(
                            controller: _emailController,
                            label: 'Email',
                            enabled: false,
                          ),
                        ],
                      ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CasalyButton(
                            text: 'Cancel',
                            onPressed: _isLoading ? null : () {
                              setState(() => _isEditing = false);
                              // Reset form
                              _displayNameController.text = userProfile.displayName ?? '';
                              _phoneController.text = userProfile.phoneNumber ?? '';
                              _emailController.text = userProfile.email;
                            },
                            variant: ButtonVariant.outline,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CasalyButton(
                            text: 'Save',
                            onPressed: _isLoading ? null : _saveProfile,
                            isLoading: _isLoading,
                            variant: ButtonVariant.primary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Logout Button
                    CasalyButton(
                      text: 'Sign Out',
                      onPressed: _showLogoutDialog,
                      variant: ButtonVariant.outline,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Delete Account Button
                    TextButton(
                      onPressed: _showDeleteAccountDialog,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      child: Text(
                        'Delete Account',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Error loading profile',
                style: AppTypography.h3.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                error.toString(),
                style: AppTypography.bodyMd,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectProfileImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cream50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cream300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Select Profile Photo',
              style: AppTypography.h3.copyWith(
                color: AppColors.green400,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: AppColors.green400),
                    title: Text('Take Photo', style: AppTypography.bodyLg),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.photo_library, color: AppColors.green400),
                    title: Text('Choose from Gallery', style: AppTypography.bodyLg),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CasalyButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
              variant: ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingImage = true);

      final user = ref.read(authStateChangesProvider).asData?.value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload image
      final imageUrl = await ref.read(uploadProfileImageProvider(UploadImageParams(
        uid: user.uid,
        imagePath: pickedFile.path,
      )).future);

      // Update profile with new image URL
      final repository = ref.read(userProfileRepositoryProvider);
      final result = await repository.updateProfileImage(user.uid, imageUrl);

      result.fold(
        (failure) => throw Exception(failure.message),
        (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile picture updated successfully!'),
                backgroundColor: AppColors.green400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile picture: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(updateUserProfileProvider(UpdateUserProfileParams(
        uid: ref.read(authStateChangesProvider).asData?.value?.uid ?? '',
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      )).future);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.green400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showLogoutDialog() {
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: AppTypography.h3.copyWith(color: AppColors.error)),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and will remove all your data.',
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
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion not implemented yet'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: Text(
              'Delete',
              style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}