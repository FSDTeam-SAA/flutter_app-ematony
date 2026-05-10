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
  late final TextEditingController _emailCtrl;
  late final TextEditingController _passCtrl;
  String _emailValue = '';
  String _passwordValue = '';
  bool _obscure = true;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: _emailValue);
    _passCtrl = TextEditingController(text: _passwordValue);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();
    final visibleError = _localError ?? controller.errorMessage;

    // Defensive: if anything (autofill, IME, hot-reload) wipes the controllers
    // but our state strings still hold the typed values, restore them so the
    // user's input never visually disappears after a failed login.
    if (_emailCtrl.text != _emailValue) {
      _emailCtrl.value = TextEditingValue(
        text: _emailValue,
        selection: TextSelection.collapsed(offset: _emailValue.length),
      );
    }
    if (_passCtrl.text != _passwordValue) {
      _passCtrl.value = TextEditingValue(
        text: _passwordValue,
        selection: TextSelection.collapsed(offset: _passwordValue.length),
      );
    }

    return AuthScaffold(
      child: Column(
        children: [
          const BrandHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue Ajo Family',
          ),
          const SizedBox(height: 32),
          if (visibleError != null) ...[
            _ErrorBanner(message: visibleError),
            const SizedBox(height: 16),
          ],
          LabeledTextField(
            label: 'Email',
            controller: _emailCtrl,
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) {
              _emailValue = v;
              if (_localError != null) setState(() => _localError = null);
              context.read<AuthController>().clearError();
            },
          ),
          const SizedBox(height: 20),
          LabeledTextField(
            label: 'Password',
            controller: _passCtrl,
            hintText: 'Enter your password',
            obscureText: _obscure,
            onChanged: (v) {
              _passwordValue = v;
              if (_localError != null) setState(() => _localError = null);
              context.read<AuthController>().clearError();
            },
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
                controller.clearError();
                setState(() => _localError = 'Please enter email and password.');
                return;
              }
              setState(() => _localError = null);
              final ok = await controller.login(email: email, password: pass);
              if (!mounted) return;
              if (!ok) {
                final msg = controller.errorMessage ?? 'Invalid email or password.';
                showError(context, msg);
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(20),
        border: Border.all(color: AppColors.danger.withAlpha(90)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
