import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../core/theme/app_colors.dart';

void _toast(String message, Color bg) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: bg,
    textColor: Colors.white,
    fontSize: 14,
  );
}

void showError(BuildContext context, String message) {
  _toast(message, AppColors.danger);
}

void showSuccess(BuildContext context, String message) {
  _toast(message, AppColors.primary);
}

void showInfo(BuildContext context, String message) {
  _toast(message, AppColors.primaryDark);
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
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

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

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

class SocialRow extends StatelessWidget {
  const SocialRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          label: 'G',
          onTap: () => showInfo(context, 'Google Sign-In coming soon.'),
        ),
        const SizedBox(width: 14),
        _SocialButton(
          icon: Icons.apple,
          onTap: () => showInfo(context, 'Apple Sign-In coming soon.'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({this.label, this.icon, this.onTap});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: Colors.white, size: 22)
            : Text(
                label ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class OtpKeypad extends StatelessWidget {
  const OtpKeypad({
    super.key,
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
                              side: const BorderSide(color: Color(0xFFD8DDD4)),
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
                                ? const Icon(Icons.backspace_outlined, color: Color(0xFF1A2E25))
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

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
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
