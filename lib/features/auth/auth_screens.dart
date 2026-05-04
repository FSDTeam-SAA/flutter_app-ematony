import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/labeled_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'auth_controller.dart';

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

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

    return _AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const BrandHeader(
            title: 'Welcome Back',
            subtitle: 'Sign in to continue your family savings journey.',
          ),
          const SizedBox(height: 28),
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
            hintText: 'Enter your password',
            obscureText: _obscure,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/forgot-password'),
              child: const Text('Forgot Password'),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Sign In',
            loading: controller.isBusy,
            onPressed: () async {
              if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
                _showError(context, 'Enter your email and password.');
                return;
              }
              final ctrl = context.read<AuthController>();
              final email = _emailCtrl.text.trim();
              final pass = _passCtrl.text.trim();
              final ok = await ctrl.login(email: email, password: pass);
              if (!mounted) return;
              if (ok) {
                context.go('/home');
              } else {
                _showError(context, ctrl.errorMessage ?? 'Unable to sign in.');
              }
            },
          ),
          const SizedBox(height: 24),
          const _OrDivider(),
          const SizedBox(height: 20),
          const _SocialRow(),
          const SizedBox(height: 32),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
              children: [
                const TextSpan(text: "Don't have an account? "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

    return _AuthScaffold(
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
          _PhoneNumberField(
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
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Create Account',
            loading: controller.isBusy,
            onPressed: !_agreeTerms
                ? null
                : () async {
                    if (_nameCtrl.text.trim().isEmpty ||
                        _emailCtrl.text.trim().isEmpty ||
                        _phoneCtrl.text.trim().isEmpty ||
                        _passCtrl.text.isEmpty ||
                        _confirmCtrl.text.isEmpty) {
                      _showError(context, 'Complete all required fields.');
                      return;
                    }
                    if (_passCtrl.text != _confirmCtrl.text) {
                      _showError(context, 'Passwords do not match.');
                      return;
                    }
                    final ctrl = context.read<AuthController>();
                    final name = _nameCtrl.text.trim();
                    final email = _emailCtrl.text.trim();
                    final phone = _phoneFull.isNotEmpty
                        ? _phoneFull
                        : '$_phoneCountryCode${_phoneCtrl.text.trim()}';
                    final pass = _passCtrl.text.trim();
                    final confirm = _confirmCtrl.text.trim();
                    final ok = await ctrl.signUp(
                      name: name,
                      email: email,
                      phone: phone,
                      password: pass,
                      confirmPassword: confirm,
                    );
                    if (!mounted) return;
                    if (ok) {
                      context.go('/kyc');
                    } else {
                      _showError(context, ctrl.errorMessage ?? 'Unable to create account.');
                    }
                  },
          ),
          const SizedBox(height: 24),
          const _OrDivider(),
          const SizedBox(height: 20),
          const _SocialRow(),
          const SizedBox(height: 28),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedText,
                  ),
              children: [
                const TextSpan(text: 'Already have an account? '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

    return _AuthScaffold(
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
              if (_emailCtrl.text.trim().isEmpty) {
                _showError(context, 'Enter your email address.');
                return;
              }
              final ctrl = context.read<AuthController>();
              final email = _emailCtrl.text.trim();
              final ok = await ctrl.forgotPassword(email);
              if (!mounted) return;
              if (ok) {
                context.push(
                  '/verify-otp?email=${Uri.encodeComponent(email)}',
                );
              } else {
                _showError(context, ctrl.errorMessage ?? 'Unable to send code.');
              }
            },
          ),
        ],
      ),
    );
  }
}

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
            _OtpKeypad(onKey: _setDigit, onDelete: _deleteDigit),
          ],
        ),
      ),
    );
  }
}

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

    return _AuthScaffold(
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
              if (_passCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
                _showError(context, 'Enter and confirm your new password.');
                return;
              }
              if (_passCtrl.text != _confirmCtrl.text) {
                _showError(context, 'Passwords do not match.');
                return;
              }
              final ctrl = context.read<AuthController>();
              final pass = _passCtrl.text.trim();
              final ok = await ctrl.resetPassword(
                email: widget.prefilledEmail ?? '',
                otp: widget.prefilledOtp ?? '',
                password: pass,
              );
              if (!mounted) return;
              if (ok) {
                context.go('/login');
              } else {
                _showError(context, ctrl.errorMessage ?? 'Unable to reset password.');
              }
            },
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, this.prefilledEmail});

  final String? prefilledEmail;

  @override
  Widget build(BuildContext context) {
    return OtpVerificationScreen(prefilledEmail: prefilledEmail);
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.child,
    this.title,
  });

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: title == null
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: Text(title!),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: child,
        ),
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

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialButton(label: 'G'),
        SizedBox(width: 14),
        _SocialButton(icon: Icons.apple),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({this.label, this.icon});

  final String? label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white)
          : Text(
              label ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _OtpKeypad extends StatelessWidget {
  const _OtpKeypad({
    required this.onKey,
    required this.onDelete,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'delete'],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: row.map((cell) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: cell.isEmpty
                        ? const SizedBox(height: 52)
                        : OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              if (cell == 'delete') {
                                onDelete();
                              } else {
                                onKey(cell);
                              }
                            },
                            child: cell == 'delete'
                                ? const Icon(Icons.backspace_outlined, color: AppColors.text)
                                : Text(
                                    cell,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
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

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.controller,
    required this.onChanged,
    this.initialCountryCode = 'BD',
  });

  final TextEditingController controller;
  final String initialCountryCode;
  final void Function(String fullNumber, String dialCode) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: controller,
          initialCountryCode: initialCountryCode,
          disableLengthCheck: false,
          dropdownIconPosition: IconPosition.trailing,
          flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 8),
          dropdownTextStyle: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Enter your phone number',
          ),
          onChanged: (phone) {
            onChanged(phone.completeNumber, phone.countryCode);
          },
        ),
      ],
    );
  }
}
