import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/member_shell.dart';
import '../auth/auth_controller.dart';

// ─── Profile Screen ───────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;

    return MemberShell(
      currentIndex: 3,
      title: 'Profile',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Avatar Card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.subtle,
                      child: Text(
                        (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.phone ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.push('/profile/personal-info'),
                  child: const Text('Change Photo'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Account Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),

          // ── Menu Items ──
          _MenuCard(
            children: [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Personal Info',
                onTap: () => context.push('/profile/personal-info'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.lock_outline,
                label: 'Password & Security',
                onTap: () => context.push('/profile/password'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.payment_outlined,
                label: 'Payments Methods',
                onTap: () => context.push('/profile/payments'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () => context.push('/profile/privacy'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.description_outlined,
                label: 'Term & Condition',
                onTap: () => context.push('/profile/terms'),
              ),
              _Divider(),
              _MenuItem(
                icon: Icons.logout,
                label: 'Logout',
                iconColor: AppColors.danger,
                labelColor: AppColors.danger,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'Are you sure want to log out?',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthController>().logout();
              if (!context.mounted) return;
              context.go('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.text),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.text,
                    ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: labelColor ?? AppColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, endIndent: 20);
  }
}

// ─── Personal Info Screen ─────────────────────────────────────────────────────

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Personal Info'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileField(label: 'Full Name', controller: _nameCtrl, hint: 'Enter Your Name'),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Email Address',
                controller: _emailCtrl,
                hint: 'Enter Your Email',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                hint: 'Enter Your Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Description',
                controller: _descCtrl,
                hint: 'Write something about you...',
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Changes saved'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Password & Security Screen ───────────────────────────────────────────────

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() => _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Password & Security'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _ProfileField(
                label: 'Current Password',
                controller: _currentCtrl,
                hint: 'Password',
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'New Password',
                controller: _newCtrl,
                hint: 'Password',
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              const SizedBox(height: 16),
              _ProfileField(
                label: 'Confirm Password',
                controller: _confirmCtrl,
                hint: 'Confirm Password',
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.mutedText,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                    context.pop();
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Payment Methods Screen ───────────────────────────────────────────────────

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _autoPay = true;
  int _selectedCard = 0;

  static const _cards = [
    _CardOption(icon: Icons.credit_card, label: 'Visa', sub: '**** **** **** 4532'),
    _CardOption(icon: Icons.credit_card, label: 'Mastercard', sub: '**** **** **** 8821'),
    _CardOption(icon: Icons.account_balance_wallet_outlined, label: 'Paypal', sub: 'user@email.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Payments Methods'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automatic Payments',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Enable to auto-pay your group contributions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoPay,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _autoPay = v),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Select Payment Method',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ..._cards.asMap().entries.map(
                    (entry) => GestureDetector(
                      onTap: () => setState(() => _selectedCard = entry.key),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedCard == entry.key ? AppColors.subtle : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCard == entry.key ? AppColors.primary : AppColors.border,
                            width: _selectedCard == entry.key ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(entry.value.icon, color: AppColors.primary, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value.label,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    entry.value.sub,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.mutedText,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedCard == entry.key)
                              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('+ Add More'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardOption {
  const _CardOption({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;
}

// ─── Privacy Policy Screen ────────────────────────────────────────────────────

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextContentScreen(
      title: 'Privacy Policy',
      content: '''Ematony Privacy Policy

Last Updated: April 2026

1. Information We Collect
We collect information you provide directly to us, such as your name, email address, phone number, and financial information when you create an account or use our services.

2. How We Use Your Information
We use the information we collect to provide, maintain, and improve our services, process transactions, send you technical notices and support messages, and respond to your comments and questions.

3. Information Sharing
We do not share your personal information with third parties except as described in this policy. We may share your information with service providers who perform services on our behalf.

4. Data Security
We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access, disclosure, alteration, and destruction.

5. Your Rights
You have the right to access, update, or delete your personal information. You may also have the right to object to or restrict certain processing of your data.

6. Contact Us
If you have any questions about this Privacy Policy, please contact us at privacy@ematony.com.''',
    );
  }
}

// ─── Terms & Conditions Screen ────────────────────────────────────────────────

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _TextContentScreen(
      title: 'Terms & Condition',
      content: '''Ematony Terms of Service

Last Updated: April 2026

1. Acceptance of Terms
By accessing or using the Ematony platform, you agree to be bound by these Terms of Service and all applicable laws and regulations.

2. User Accounts
You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.

3. Savings Groups
Members of a savings group agree to make timely contributions as specified by the group rules. Failure to contribute may result in removal from the group and forfeiture of your position in the rotation schedule.

4. Payments
All payments are processed securely through our payment partners. We are not responsible for delays caused by your bank or payment provider.

5. Termination
We reserve the right to terminate or suspend your account at any time for violation of these terms or for any other reason at our sole discretion.

6. Limitation of Liability
Ematony shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.

7. Governing Law
These Terms shall be governed by and construed in accordance with the laws of Nigeria.''',
    );
  }
}

class _TextContentScreen extends StatelessWidget {
  const _TextContentScreen({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
                height: 1.7,
              ),
        ),
      ),
    );
  }
}

// ─── Shared Widget ────────────────────────────────────────────────────────────

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            fillColor: readOnly ? AppColors.background : Colors.white,
          ),
        ),
      ],
    );
  }
}
