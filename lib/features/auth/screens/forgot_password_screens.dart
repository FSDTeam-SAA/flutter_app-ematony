import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_header.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../auth_controller.dart';
import '../widgets/auth_utils.dart';

// ─── ForgotPasswordScreen ─────────────────────────────────────────────────────

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
    final controller = context.watch<AuthController>();

    return AuthScaffold(
      title: 'Forgot Password',
      child: Column(
        children: [
          const BrandHeader(
            title: 'Forgot Password',
            subtitle: 'Enter your email address and we will send you a code.',
          ),
          const SizedBox(height: 28),
          LabeledTextField(
            label: 'Email Address',
            controller: _emailCtrl,
            hintText: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Send Code',
            loading: controller.isBusy,
            onPressed: () async {
              final email = _emailCtrl.text.trim();
              if (email.isEmpty) {
                showError(context, 'Enter your email address.');
                return;
              }
              final ok = await controller.forgotPassword(email);
              if (ok && mounted) {
                context.push('/verify-otp?email=${Uri.encodeComponent(email)}');
              } else if (!ok && mounted) {
                showError(context, controller.errorMessage ?? 'Unable to send code.');
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── OtpVerificationScreen ───────────────────────────────────────────────────

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key, this.prefilledEmail});

  final String? prefilledEmail;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((controller) => controller.text).join();

  void _setDigit(String digit) {
    for (final controller in _otpControllers) {
      if (controller.text.isEmpty) {
        setState(() => controller.text = digit);
        break;
      }
    }
  }

  void _deleteDigit() {
    for (final controller in _otpControllers.reversed) {
      if (controller.text.isNotEmpty) {
        setState(() => controller.text = '');
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    const BrandHeader(
                      title: 'Verify Code',
                      subtitle: 'Enter the 6-digit code sent to your email address.',
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final hasValue = _otpControllers[index].text.isNotEmpty;
                        return Container(
                          width: 46,
                          height: 58,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: hasValue ? AppColors.primary : AppColors.border,
                              width: hasValue ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            _otpControllers[index].text,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Resend code'),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: 'Verify',
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
            OtpKeypad(onKey: _setDigit, onDelete: _deleteDigit),
          ],
        ),
      ),
    );
  }
}

// ─── NewPasswordScreen ───────────────────────────────────────────────────────

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
    final controller = context.watch<AuthController>();

    return AuthScaffold(
      title: 'Create New Password',
      child: Column(
        children: [
          const BrandHeader(
            title: 'Create New Password',
            subtitle: 'Use a strong password you have not used before.',
          ),
          const SizedBox(height: 28),
          LabeledTextField(
            label: 'Password',
            controller: _passCtrl,
            hintText: 'Enter your new password',
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
            hintText: 'Confirm your new password',
            obscureText: _obscureConfirm,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Continue',
            loading: controller.isBusy,
            onPressed: () async {
              final pass = _passCtrl.text.trim();
              final confirm = _confirmCtrl.text.trim();
              if (pass.isEmpty || confirm.isEmpty) {
                showError(context, 'Enter and confirm your new password.');
                return;
              }
              if (pass != confirm) {
                showError(context, 'Passwords do not match.');
                return;
              }
              final ok = await controller.resetPassword(
                email: widget.prefilledEmail ?? '',
                otp: widget.prefilledOtp ?? '',
                password: pass,
              );
              if (ok && mounted) {
                showSuccess(context, 'Password reset! Please sign in.');
                context.go('/login');
              } else if (!ok && mounted) {
                showError(context, controller.errorMessage ?? 'Unable to reset password.');
              }
            },
          ),
        ],
      ),
    );
  }
}
