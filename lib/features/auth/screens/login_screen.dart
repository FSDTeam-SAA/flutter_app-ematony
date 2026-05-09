import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../auth_controller.dart';
import '../widgets/auth_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: '');
  final _passCtrl = TextEditingController(text: '');
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return AuthScaffold(
      child: Column(
        children: [
          const BrandHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue Ajo Family',
          ),
          const SizedBox(height: 32),
          LabeledTextField(
            label: 'Email',
            controller: _emailCtrl,
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          LabeledTextField(
            label: 'Password',
            controller: _passCtrl,
            hintText: 'Enter your password',
            obscureText: _obscure,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.mutedText,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Sign In',
            loading: controller.isBusy,
            onPressed: () async {
              final email = _emailCtrl.text.trim();
              final pass = _passCtrl.text;
              if (email.isEmpty || pass.isEmpty) {
                showError(context, 'Please enter email and password.');
                return;
              }
              final ok = await controller.login(email: email, password: pass);
              if (ok && mounted) {
                // Navigation handled by router redirect
              } else if (!ok && mounted) {
                showError(context, controller.errorMessage ?? 'Invalid credentials.');
              }
            },
          ),
          const SizedBox(height: 24),
          const OrDivider(),
          const SizedBox(height: 24),
          const SocialRow(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
