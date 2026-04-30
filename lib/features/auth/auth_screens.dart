import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import 'auth_controller.dart';

void _showError(BuildContext context, String? message) {
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/ajo-family.png',
        width: 140,
        fit: BoxFit.contain,
      );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(loadingLabel ?? label),
                ],
              )
            : Text(label),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialBtn(
          child: Image.asset('assets/google_icon.png', width: 22,
              errorBuilder: (_, __, ___) =>
                  const Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 16),
        const _SocialBtn(
          child: Icon(Icons.apple, color: Colors.white, size: 24),
        ),
      ],
    );
  }
}

class _SocialBtn extends StatelessWidget {
  const _SocialBtn({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

// ─── Login Screen ─────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@gmail.com');
  final _passCtrl = TextEditingController(text: '123456');
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const _Logo(),
              const SizedBox(height: 24),
              Text(
                'Welcome Back',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to continue Ajo Family',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              const SizedBox(height: 32),
              _AuthField(
                label: 'Email Address',
                controller: _emailCtrl,
                hint: 'Enter Your Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Password',
                controller: _passCtrl,
                hint: 'Enter Your Password',
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PrimaryButton(
                label: 'Sign In',
                loadingLabel: 'Signing in...',
                loading: ctrl.isBusy,
                onPressed: () async {
                  final ok = await ctrl.login(
                    email: _emailCtrl.text.trim(),
                    password: _passCtrl.text,
                  );
                  if (!mounted) return;
                  if (ok) {
                    context.go('/home');
                  } else {
                    _showError(context, ctrl.errorMessage);
                  }
                },
              ),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 24),
              const _SocialButtons(),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => context.push('/signup'),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                    children: const [
                      TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sign Up Screen ───────────────────────────────────────────────────────────

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _agreeTerms = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const _Logo(),
              const SizedBox(height: 16),
              Text(
                'Create Your Account',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start your journey with Ajo Family',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              const SizedBox(height: 28),
              _AuthField(
                label: 'Your Name',
                controller: _nameCtrl,
                hint: 'Enter Your Name',
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                hint: 'Enter Your Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Email Address',
                controller: _emailCtrl,
                hint: 'Enter Your Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Password',
                controller: _passCtrl,
                hint: 'Enter Your Password',
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Confirm Password',
                controller: _confirmCtrl,
                hint: 'Confirm Your Password',
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeTerms,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                          children: const [
                            TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: TextStyle(
                                color: AppColors.primary,
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
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'Create Account',
                loadingLabel: 'Creating...',
                loading: ctrl.isBusy,
                onPressed: !_agreeTerms
                    ? null
                    : () async {
                        final ok = await ctrl.signUp(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                          password: _passCtrl.text,
                          confirmPassword: _confirmCtrl.text,
                        );
                        if (!mounted) return;
                        if (ok) {
                          context.go('/home');
                        } else {
                          _showError(context, ctrl.errorMessage);
                        }
                      },
              ),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 24),
              const _SocialButtons(),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                    children: const [
                      TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Forgot Password Screen ───────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const _Logo(),
              const SizedBox(height: 24),
              Text(
                'Forgot Your Password?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email to receive a code',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _AuthField(
                label: 'Email Address',
                controller: _emailCtrl,
                hint: 'Enter Your Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              _PrimaryButton(
                label: 'Send Code',
                loadingLabel: 'Sending...',
                loading: ctrl.isBusy,
                onPressed: () async {
                  final ok = await ctrl.forgotPassword(_emailCtrl.text.trim());
                  if (!mounted) return;
                  if (ok) {
                    context.push(
                      '/verify-otp?email=${Uri.encodeComponent(_emailCtrl.text.trim())}',
                    );
                  } else {
                    _showError(context, ctrl.errorMessage);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── OTP Verification Screen ──────────────────────────────────────────────────

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.prefilledEmail});

  final String? prefilledEmail;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((c) => c.text).join();

  void _onKeyTap(String key) {
    for (int i = 0; i < 6; i++) {
      if (_otpControllers[i].text.isEmpty) {
        setState(() => _otpControllers[i].text = key);
        if (i < 5) _focusNodes[i + 1].requestFocus();
        return;
      }
    }
  }

  void _onBackspace() {
    for (int i = 5; i >= 0; i--) {
      if (_otpControllers[i].text.isNotEmpty) {
        setState(() => _otpControllers[i].text = '');
        if (i > 0) _focusNodes[i - 1].requestFocus();
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    const _Logo(),
                    const SizedBox(height: 24),
                    Text(
                      'Verify Your Email',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-digit code sent to your email',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedText,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _focusNodes[i],
                            readOnly: true,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.text,
                                ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _otpControllers[i].text.isNotEmpty
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Resend code',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PrimaryButton(
                      label: 'Verify',
                      loadingLabel: 'Verifying...',
                      loading: ctrl.isBusy,
                      onPressed: _otp.length < 6
                          ? null
                          : () {
                              context.push(
                                '/new-password?email=${Uri.encodeComponent(widget.prefilledEmail ?? '')}&otp=${Uri.encodeComponent(_otp)}',
                              );
                            },
                    ),
                  ],
                ),
              ),
            ),
            _NumPad(onKey: _onKeyTap, onBackspace: _onBackspace),
          ],
        ),
      ),
    );
  }
}

class _NumPad extends StatelessWidget {
  const _NumPad({required this.onKey, required this.onBackspace});

  final void Function(String) onKey;
  final VoidCallback onBackspace;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['0', 'X'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: _keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                final isBackspace = key == 'X';
                return SizedBox(
                  width: 80,
                  height: 52,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isBackspace ? onBackspace : () => onKey(key),
                    child: isBackspace
                        ? const Icon(Icons.backspace_outlined, color: AppColors.text, size: 20)
                        : Text(
                            key,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                          ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── New Password Screen ──────────────────────────────────────────────────────

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key, this.prefilledEmail, this.prefilledOtp});

  final String? prefilledEmail;
  final String? prefilledOtp;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const _Logo(),
              const SizedBox(height: 24),
              Text(
                'Create a New Password',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a password different from previous ones',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _AuthField(
                label: 'Password',
                controller: _passCtrl,
                hint: 'Enter Your Password',
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 16),
              _AuthField(
                label: 'Confirm Password',
                controller: _confirmCtrl,
                hint: 'Confirm Your Password',
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 32),
              _PrimaryButton(
                label: 'Continue',
                loadingLabel: 'Saving...',
                loading: ctrl.isBusy,
                onPressed: () async {
                  final ok = await ctrl.resetPassword(
                    email: widget.prefilledEmail ?? '',
                    otp: widget.prefilledOtp ?? '',
                    password: _passCtrl.text,
                  );
                  if (!mounted) return;
                  if (ok) {
                    context.go('/login');
                  } else {
                    _showError(context, ctrl.errorMessage);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Reset Password (legacy compat) ──────────────────────────────────────────

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, this.prefilledEmail});
  final String? prefilledEmail;

  @override
  Widget build(BuildContext context) => OtpVerificationScreen(prefilledEmail: prefilledEmail);
}
