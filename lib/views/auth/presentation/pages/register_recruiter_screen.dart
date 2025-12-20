// lib/views/auth/presentation/pages/register_recruiter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/views/auth/logic/cubit/auth_cubit.dart';
import 'package:flutter_alinfo9/views/auth/logic/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterRecruiterScreen extends StatelessWidget {
  const RegisterRecruiterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(AuthRepository()),
      child: const RegisterRecruiterView(),
    );
  }
}

class RegisterRecruiterView extends StatefulWidget {
  const RegisterRecruiterView({super.key});

  @override
  State<RegisterRecruiterView> createState() => _RegisterRecruiterViewState();
}

class _RegisterRecruiterViewState extends State<RegisterRecruiterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _websiteController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _websiteController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      context.read<AuthCubit>().registerRecruiter(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        companyName: _companyController.text.trim(),
        website: _websiteController.text.trim().isNotEmpty
            ? _websiteController.text.trim()
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            // Registration succeeded and auto-login completed
            final route = context.read<AuthCubit>().getRedirectRoute(state.response.role);
            Navigator.of(context).pushReplacementNamed(route);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recruiter Registration',
                      style: TextStyle(
                        color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in your details to get started',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textGrey
                            : AppTheme.textDarkGrey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomTextField(
                          label: 'Email',
                          hint: 'Enter your email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomTextField(
                          label: 'Company Name',
                          hint: 'Enter your company name',
                          controller: _companyController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your company name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomTextField(
                          label: 'Website (Optional)',
                          hint: 'Enter company website',
                          controller: _websiteController,
                          keyboardType: TextInputType.url,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomTextField(
                          label: 'Password',
                          hint: 'Create a password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AbsorbPointer(
                      absorbing: isLoading,
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: CustomTextField(
                          label: 'Confirm Password',
                          hint: 'Confirm your password',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDark
                                  ? AppTheme.textGrey
                                  : AppTheme.textDarkGrey,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
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
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.textGrey
                                : AppTheme.textDarkGrey,
                          ),
                        ),
                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () => Navigator.of(
                                  context,
                                ).pushReplacementNamed('/login'),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: isLoading
                                  ? AppTheme.accentBlue.withOpacity(0.5)
                                  : AppTheme.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
