import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../providers/dorm_providers.dart';

class CreateDormScreen extends ConsumerStatefulWidget {
  const CreateDormScreen({super.key});

  @override
  ConsumerState<CreateDormScreen> createState() => _CreateDormScreenState();
}

class _CreateDormScreenState extends ConsumerState<CreateDormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createDorm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final params = CreateDormParams(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
      );

      final dorm = await ref.read(createDormProvider(params).future);
      
      if (mounted) {
        context.go('/dorm');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dorm "${dorm.name}" created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create dorm: $e'),
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
        title: Text('Create Dorm', style: AppTypography.h2),
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
                'Create your shared living space',
                style: AppTypography.h1.copyWith(color: AppColors.cream800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Give your dorm a name that everyone will recognize. You\'ll get an invite code to share with your housemates.',
                style: AppTypography.bodyMd.copyWith(color: AppColors.cream600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              CasalyTextField(
                controller: _nameController,
                label: 'Dorm Name',
                hint: 'e.g., "Building A Floor 3" or "The Squad House"',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a dorm name';
                  }
                  if (value.trim().length < 2) {
                    return 'Dorm name must be at least 2 characters';
                  }
                  if (value.trim().length > 50) {
                    return 'Dorm name must be less than 50 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              
              CasalyTextField(
                controller: _descriptionController,
                label: 'Description (Optional)',
                hint: 'Add any details about your shared living space...',
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.trim().length > 200) {
                    return 'Description must be less than 200 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.green50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.green200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.group,
                      color: AppColors.green400,
                      size: 32,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'What happens next?',
                      style: AppTypography.labelLg.copyWith(color: AppColors.green800),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'You\'ll become the admin and get a 6-character invite code. Share this code with your housemates so they can join!',
                      style: AppTypography.bodySm.copyWith(color: AppColors.green600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              
              CasalyButton(
                text: 'Create Dorm',
                onPressed: _isLoading ? null : _createDorm,
                isLoading: _isLoading,
                variant: ButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}