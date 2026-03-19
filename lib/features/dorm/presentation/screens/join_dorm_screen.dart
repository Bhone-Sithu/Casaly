import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/invite_code_generator.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../providers/dorm_providers.dart';

class JoinDormScreen extends ConsumerStatefulWidget {
  const JoinDormScreen({super.key});

  @override
  ConsumerState<JoinDormScreen> createState() => _JoinDormScreenState();
}

class _JoinDormScreenState extends ConsumerState<JoinDormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinDorm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final inviteCode = _inviteCodeController.text.trim().toUpperCase();
      final dorm = await ref.read(joinDormProvider(inviteCode).future);
      
      if (mounted) {
        context.go('/dorm');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully joined "${dorm.name}"!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join dorm: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream50,
      appBar: AppBar(
        title: Text('Join Dorm', style: AppTypography.h2),
        backgroundColor: AppColors.cream50,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream800),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Join your housemates',
                style: AppTypography.h1.copyWith(color: AppColors.cream800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter the 6-character invite code that your housemate shared with you.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              CasalyTextField(
                controller: _inviteCodeController,
                label: 'Invite Code',
                hint: 'ABC123',
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an invite code';
                  }
                  final code = value.trim().toUpperCase();
                  if (!InviteCodeGenerator.isValid(code)) {
                    return 'Invite code must be 6 characters (letters and numbers only)';
                  }
                  return null;
                },
                onChanged: (value) {
                  _inviteCodeController.value = _inviteCodeController.value.copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.orange50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.orange200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.orange400,
                      size: 24,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Don\'t have an invite code?',
                      style: AppTypography.labelLg.copyWith(color: AppColors.orange800),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ask a housemate who already joined to share the code, or create a new dorm if you\'re the first one setting up.',
                      style: AppTypography.bodySm.copyWith(color: AppColors.orange600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              CasalyButton(
                text: 'Join Dorm',
                onPressed: _isLoading ? null : _joinDorm,
                isLoading: _isLoading,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              CasalyButton(
                text: 'Create New Dorm Instead',
                onPressed: () => context.go('/create-dorm'),
                variant: ButtonVariant.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}