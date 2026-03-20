
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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoadingEmail) return; // Prevent multiple taps

    setState(() => _isLoadingEmail = true);

    try {
      
      final user = await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      
      if (mounted && user != null) {
        context.go('/dorm-selection');
      } else if (mounted && user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up failed: No user returned'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      
      if (mounted) {
        // Extract user-friendly message from exception
        String errorMessage = 'Sign up failed';
        if (e is Exception) {
          final String exceptionMessage = e.toString();
          if (exceptionMessage.startsWith('Exception: ')) {
            errorMessage = exceptionMessage.substring('Exception: '.length);
          } else {
            errorMessage = exceptionMessage;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
    if (_isLoadingGoogle) return; // Prevent multiple taps
    
    setState(() => _isLoadingGoogle = true);

    try {
      
      // Add additional safety check
      if (!mounted) {
        return;
      }
      
      final user = await ref.read(authRepositoryProvider).signInWithGoogle();
      
      if (mounted && user != null) {
        context.go('/dorm-selection');
      } else {
        if (mounted && user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In was cancelled'),
              backgroundColor: AppColors.cream400,
            ),
          );
        }
      }
    } catch (e) {
      
      if (mounted) {
        // Extract user-friendly message from exception
        String errorMessage = 'Google Sign-In failed';
        if (e is Exception) {
          final String exceptionMessage = e.toString();
          if (exceptionMessage.startsWith('Exception: ')) {
            errorMessage = exceptionMessage.substring('Exception: '.length);
          } else {
            errorMessage = exceptionMessage;
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
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
                const SizedBox(height: AppSpacing.xl),
                
                // Back Button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.cream800),
                  ),
                ),
                
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
                        Icons.person_add,
                        size: 48,
                        color: AppColors.green400,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Join Casaly',
                        style: AppTypography.h1.copyWith(
                          color: AppColors.green400,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Create your account to get started',
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
                  text: 'Sign up with Google',
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
                  hint: 'Create a strong password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                // Confirm Password Field
                CasalyTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Sign Up Button
                CasalyButton(
                  text: 'Create Account',
                  onPressed: _isLoadingEmail ? null : _signUpWithEmail,
                  isLoading: _isLoadingEmail,
                  variant: ButtonVariant.primary,
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Login Link
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.cream600,
                        ),
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: 'Sign in',
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
