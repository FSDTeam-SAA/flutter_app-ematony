import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/mock/app_mock_data.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';
import '../../core/widgets/labeled_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_models.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class ProfileRepository {
  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AppUser> getProfile() async {
    try {
      final response =
          await _apiClient.dio.get<Map<String, dynamic>>('/user/profile');
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AppUser.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<AppUser> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? imageFilePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
        if (imageFilePath != null)
          'avatar': await MultipartFile.fromFile(
            imageFilePath,
            filename: 'avatar.jpg',
          ),
      });
      final response = await _apiClient.dio.put<Map<String, dynamic>>(
        '/user/profile',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      return AppUser.fromJson(data);
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      throw Exception(msg ?? 'Failed to update profile.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.dio.put<Map<String, dynamic>>(
        '/user/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      final msg = () {
        try {
          final d = e.response?.data;
          if (d is Map) return d['message']?.toString();
        } catch (_) {}
        return null;
      }();
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        await AppMockData.simulateDelay();
        return;
      }
      throw Exception(msg ?? 'Failed to change password.');
    }
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ProfileController extends ChangeNotifier {
  ProfileController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  bool isSaving = false;
  String? error;
  String? successMessage;

  Future<bool> saveProfile({
    required AppUser current,
    required String name,
    required String phone,
    required String bio,
    required AuthController authCtrl,
    String? imageFilePath,
  }) async {
    isSaving = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        imageFilePath: imageFilePath,
      );
      await authCtrl.updateProfile(updated);
      successMessage = 'Profile updated successfully.';
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    isSaving = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      successMessage = 'Password changed successfully.';
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}

// ─── ProfileScreen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final name = user?.name.isNotEmpty == true ? user!.name : 'Ematony';
    final email =
        user?.email.isNotEmpty == true ? user!.email : 'ematony@example.com';
    final phone =
        user?.phone?.isNotEmpty == true ? user!.phone! : '+123-456 789';

    return AjoScaffold(
      currentIndex: 3,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AjoPatternHeader(
                height: 234,
                bottomRadius: 28,
                child: Column(
                  children: [
                    const SizedBox(height: 34),
                    AjoAvatar(name: name, radius: 34),
                    const SizedBox(height: 14),
                    Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white.withAlpha(210)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white.withAlpha(210)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                child: Text(
                  'Account Settings',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Info',
                      onTap: () => context.push('/profile/personal-info'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Password & Security',
                      onTap: () => context.push('/profile/password'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileTile(
                      icon: Icons.credit_card_outlined,
                      label: 'Payments Methods',
                      onTap: () => context.push('/profile/payments'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileTile(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                      onTap: () => context.push('/profile/privacy'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileTile(
                      icon: Icons.fact_check_outlined,
                      label: 'Term & Condition',
                      onTap: () => context.push('/profile/terms'),
                    ),
                    const SizedBox(height: 10),
                    _ProfileTile(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      danger: true,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final auth = context.read<AuthController>();
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withAlpha(110),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded,
                    size: 52, color: Colors.white),
                const SizedBox(height: 18),
                Text(
                  'Are you sure want to log out?',
                  textAlign: TextAlign.center,
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFF9F1DF),
                            foregroundColor: AppColors.primaryDark,
                          ),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFFF1733),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            Navigator.of(dialogContext).pop();
                            await auth.logout();
                            if (!context.mounted) return;
                            context.go('/login');
                          },
                          child: const Text('Log Out'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── PersonalInfoScreen ───────────────────────────────────────────────────────

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  File? _pickedImage;
  bool _pickingImage = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _bioCtrl = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _pickingImage = true);
    try {
      final picker = ImagePicker();
      final result = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined,
                    color: AppColors.primaryDark),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primaryDark),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
      if (result == null) return;
      final xFile = await picker.pickImage(
        source: result,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (xFile != null) {
        setState(() => _pickedImage = File(xFile.path));
      }
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfileController>();
    final user = context.read<AuthController>().currentUser;

    return _ProfileFormScaffold(
      title: 'Personal Info',
      loading: ctrl.isSaving,
      child: Column(
        children: [
          // ── Avatar with edit badge ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _pickedImage != null
                    ? CircleAvatar(
                        radius: 54,
                        backgroundImage: FileImage(_pickedImage!),
                      )
                    : user?.avatarUrl != null
                        ? CircleAvatar(
                            radius: 54,
                            backgroundImage:
                                NetworkImage(user!.avatarUrl!),
                            onBackgroundImageError: (_, _) {},
                            child: null,
                          )
                        : AjoAvatar(
                            name: _nameCtrl.text.isEmpty
                                ? 'A'
                                : _nameCtrl.text,
                            radius: 54,
                          ),
              ),
              Positioned(
                right: -2,
                bottom: 4,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF4EC),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: _pickingImage
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryDark),
                          )
                        : const Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.primaryDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickImage,
            child: const Text('Change Photo'),
          ),
          if (_pickedImage != null)
            Text(
              'Photo selected — save to upload',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          const SizedBox(height: 10),
          LabeledTextField(label: 'Full Name', controller: _nameCtrl),
          const SizedBox(height: 14),
          LabeledTextField(
            label: 'Email Address',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          LabeledTextField(
            label: 'Phone Number',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          LabeledTextField(
            label: 'Description',
            controller: _bioCtrl,
            hintText: 'Write a description about you...',
            maxLines: 4,
          ),
          if (ctrl.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(ctrl.error!,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          if (ctrl.successMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(ctrl.successMessage!,
                  style: const TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      onSave: () async {
        final authCtrl = context.read<AuthController>();
        final profileCtrl = context.read<ProfileController>();
        final name = _nameCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();
        final bio = _bioCtrl.text.trim();
        final imagePath = _pickedImage?.path;
        final ok = await profileCtrl.saveProfile(
          current: authCtrl.currentUser!,
          name: name,
          phone: phone,
          bio: bio,
          authCtrl: authCtrl,
          imageFilePath: imagePath,
        );
        if (!mounted) return;
        if (ok) {
          setState(() => _pickedImage = null);
          if (context.mounted) context.pop();
        }
      },
    );
  }
}

// ─── PasswordSecurityScreen ───────────────────────────────────────────────────

class PasswordSecurityScreen extends StatefulWidget {
  const PasswordSecurityScreen({super.key});

  @override
  State<PasswordSecurityScreen> createState() =>
      _PasswordSecurityScreenState();
}

class _PasswordSecurityScreenState extends State<PasswordSecurityScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfileController>();

    return _ProfileFormScaffold(
      title: 'Password & Security',
      loading: ctrl.isSaving,
      child: Column(
        children: [
          LabeledTextField(
            label: 'Current Password',
            controller: _currentCtrl,
            hintText: '**********',
            obscureText: true,
          ),
          const SizedBox(height: 14),
          LabeledTextField(
            label: 'New Password',
            controller: _newCtrl,
            hintText: '**********',
            obscureText: true,
          ),
          const SizedBox(height: 14),
          LabeledTextField(
            label: 'Confirm Password',
            controller: _confirmCtrl,
            hintText: '**********',
            obscureText: true,
          ),
          if (ctrl.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(ctrl.error!,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          if (ctrl.successMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(ctrl.successMessage!,
                  style: const TextStyle(color: AppColors.primary)),
            ),
        ],
      ),
      onSave: () async {
        if (_currentCtrl.text.isEmpty ||
            _newCtrl.text.isEmpty ||
            _confirmCtrl.text.isEmpty) {
          return;
        }
        if (_newCtrl.text != _confirmCtrl.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwords do not match.'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }
        final profileCtrl = context.read<ProfileController>();
        final ok = await profileCtrl.changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
          confirmPassword: _confirmCtrl.text,
        );
        if (!mounted) return;
        if (ok) {
          _currentCtrl.clear();
          _newCtrl.clear();
          _confirmCtrl.clear();
        }
      },
    );
  }
}

// ─── PaymentMethodsScreen ─────────────────────────────────────────────────────

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _autoPay = true;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AjoBackHeader(title: 'Payments Methods'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AjoCard(
                    radius: 18,
                    borderColor: const Color(0xFFF0E2C9),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Automatic Payments',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        _TogglePill(
                          value: _autoPay,
                          onChanged: (v) => setState(() => _autoPay = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Topup Method',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _PaymentMethodTile(
                    title: 'Visa',
                    subtitle: 'Pay securely with your credit or debit card',
                    iconLabel: 'VISA',
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    title: 'Mastercard',
                    subtitle: 'Pay securely with your credit or debit card',
                    iconLabel: 'MC',
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodTile(
                    title: 'Paypal',
                    subtitle: 'Pay with your PayPal account',
                    iconLabel: 'PP',
                    isSelected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Add More',
                    icon: Icons.add,
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Add payment method coming soon.'),
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PrivacyPolicyScreen / TermsConditionsScreen ──────────────────────────────

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TextScreen(
      title: 'Privacy Policy',
      body:
          'Ajo Family collects the information required to manage your account, '
          'support contributions, and complete security checks. We use trusted '
          'providers for identity verification and payment processing, and we do '
          'not sell your personal data.\n\n'
          'Your data is encrypted in transit and at rest. You may request deletion '
          'of your account and associated data at any time by contacting support.',
    );
  }
}

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TextScreen(
      title: 'Terms & Condition',
      body:
          'By using Ajo Family, you agree to provide accurate information, keep '
          'your account secure, and participate responsibly in group savings '
          'activities. Verification may be required before wallet and payout '
          'features are fully enabled.\n\n'
          'All group contributions are binding once confirmed. Ajo Family reserves '
          'the right to suspend accounts that violate community guidelines or '
          'engage in fraudulent activity.',
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final iconBg =
        danger ? const Color(0xFFFFF0F0) : const Color(0xFFF6FBF7);
    final iconColor = danger ? AppColors.danger : AppColors.primaryDark;

    return GestureDetector(
      onTap: onTap,
      child: AjoCard(
        radius: 16,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 24, color: AppColors.text),
          ],
        ),
      ),
    );
  }
}

class _ProfileFormScaffold extends StatelessWidget {
  const _ProfileFormScaffold({
    required this.title,
    required this.child,
    required this.onSave,
    this.loading = false,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AjoBackHeader(title: title),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                children: [
                  Expanded(child: SingleChildScrollView(child: child)),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    label: 'Save Changes',
                    loading: loading,
                    onPressed: onSave,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.iconLabel,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconLabel;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                iconLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: const Color(0xFF93A2BB)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFDFE5DA),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F1DF),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TextScreen extends StatelessWidget {
  const _TextScreen({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AjoBackHeader(title: title),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(
                body,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
