
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/casaly_button.dart';
import '../../../../core/widgets/casaly_text_field.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoadingEmail = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (mounted && user != null) {
        context.go('/dorm-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingEmail = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoadingGoogle = true);

    try {
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      
      if (mounted && user != null) {
        context.go('/dorm-selection');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGoogle = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xxxl),
                
                // Logo/Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home,
                        size: 48,
                        color: AppColors.green400,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Welcome back',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.green400,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sign in to continue to Casaly',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.green600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Google Sign-In Button
                GoogleSignInButton(
                  onPressed: _signInWithGoogle,
                  isLoading: _isLoadingGoogle,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.cream200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Text(
                        'OR',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.cream400,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.cream200)),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Email Field
                CasalyTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email address',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Password Field
                CasalyTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Login Button
                CasalyButton(
                  text: 'Sign In',
                  onPressed: _isLoadingEmail ? null : _signInWithEmail,
                  isLoading: _isLoadingEmail,
                  variant: ButtonVariant.primary,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Sign Up Link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/signup'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.cream600,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Sign up',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.green400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
