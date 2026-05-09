import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../auth_controller.dart';
import '../widgets/auth_utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _phoneCountryCode = '+880';
  String _phoneFull = '';
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreeTerms = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return AuthScaffold(
      title: 'Create Account',
      child: Column(
        children: [
          const BrandHeader(
            title: 'Create Your Account',
            subtitle: 'Save with the people you trust most.',
          ),
          const SizedBox(height: 28),
          LabeledTextField(
            label: 'Your Name',
            controller: _nameCtrl,
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          PhoneNumberField(
            controller: _phoneCtrl,
            initialCountryCode: 'BD',
            onChanged: (full, dialCode) {
              _phoneCountryCode = dialCode;
              _phoneFull = full;
            },
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Email Address',
            controller: _emailCtrl,
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Password',
            controller: _passCtrl,
            hintText: 'Create a password',
            obscureText: _obscurePass,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
              icon: Icon(
                _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LabeledTextField(
            label: 'Confirm Password',
            controller: _confirmCtrl,
            hintText: 'Confirm your password',
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _agreeTerms,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (value) => setState(() => _agreeTerms = value ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'I agree to the Terms & Conditions and understand my account requires identity verification.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                          height: 1.5,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Create Account',
            loading: controller.isBusy,
            onPressed: () async {
              if (!_agreeTerms) {
                showError(context, 'Please agree to terms & conditions.');
                return;
              }
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              final pass = _passCtrl.text;
              final confirm = _confirmCtrl.text;

              if (name.isEmpty || email.isEmpty || _phoneFull.isEmpty || pass.isEmpty) {
                showError(context, 'Please complete all fields.');
                return;
              }
              if (pass != confirm) {
                showError(context, 'Passwords do not match.');
                return;
              }

              final ok = await controller.signUp(
                name: name,
                email: email,
                phone: _phoneFull,
                password: pass,
                confirmPassword: confirm,
              );
              if (ok && mounted) {
                showSuccess(context, 'Registration successful! Please sign in.');
                context.go('/login');
              } else if (!ok && mounted) {
                showError(context, controller.errorMessage ?? 'Registration failed.');
              }
            },
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account?",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
