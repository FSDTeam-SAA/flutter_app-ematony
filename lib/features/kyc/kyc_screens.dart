import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/labeled_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../auth/auth_controller.dart';

void _showKycMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.danger : AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

String _extractDioMessage(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return (data['message'] ?? data['error'] ?? 'Request failed').toString();
    }
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Cannot reach the server. Check your connection or try again.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return error.message ?? 'Request failed';
    }
  }
  return 'Something went wrong. Please try again.';
}

class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Identity Verification',
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.subtle,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(40), width: 2),
            ),
            child: const Icon(Icons.shield_outlined, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 28),
          Text(
            'Verify Your Identity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We need to verify your identity before you can fully participate in savings rotations, payouts, and wallet activity. Verification is powered by Stripe Identity.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Start Verification',
            onPressed: () => context.push('/kyc/personal-info'),
          ),
        ],
      ),
    );
  }
}

class KycPersonalInfoScreen extends StatefulWidget {
  const KycPersonalInfoScreen({super.key});

  @override
  State<KycPersonalInfoScreen> createState() => _KycPersonalInfoScreenState();
}

class _KycPersonalInfoScreenState extends State<KycPersonalInfoScreen> {
  late final TextEditingController _nameCtrl;
  final _dobCtrl = TextEditingController();
  DateTime? _dob;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  final _addressCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select Date of Birth',
    );
    if (picked == null) return;
    setState(() {
      _dob = picked;
      _dobCtrl.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

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
    _dobCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: 'Personal Information',
      children: [
        LabeledTextField(
          label: 'Full Name',
          controller: _nameCtrl,
          hintText: 'Enter your full name',
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Date of Birth',
          controller: _dobCtrl,
          hintText: 'DD/MM/YYYY',
          readOnly: true,
          onTap: _pickDob,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.mutedText),
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Email',
          controller: _emailCtrl,
          hintText: 'Enter your email address',
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Phone Number',
          controller: _phoneCtrl,
          hintText: 'Enter your phone number',
          keyboardType: TextInputType.phone,
          readOnly: true,
        ),
        const SizedBox(height: 16),
        LabeledTextField(
          label: 'Address',
          controller: _addressCtrl,
          hintText: 'Street, city, state',
          maxLines: 3,
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          loading: _isSaving,
          label: 'Continue',
          onPressed: () async {
            if (_nameCtrl.text.trim().isEmpty ||
                _dobCtrl.text.trim().isEmpty ||
                _emailCtrl.text.trim().isEmpty ||
                _phoneCtrl.text.trim().isEmpty ||
                _addressCtrl.text.trim().isEmpty) {
              _showKycMessage(context, 'Complete all personal information fields.', error: true);
              return;
            }

            setState(() => _isSaving = true);
            try {
              await context.read<ApiClient>().dio.put(
                    '/kyc/personal-info',
                    data: {
                      'fullName': _nameCtrl.text.trim(),
                      'dob': _dobCtrl.text.trim(),
                      'addressLine1': _addressCtrl.text.trim(),
                      'addressLine2': '',
                      'city': '',
                      'state': '',
                      'postalCode': '',
                      'country': 'NG',
                    },
                  );
            } catch (_) {
              // KYC can continue in demo mode when the backend is unavailable.
            } finally {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            }
            if (!mounted) return;
            context.push('/kyc/document');
          },
        ),
      ],
    );
  }
}

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  int _selected = 0;
  bool _isSaving = false;

  static const _options = [
    'Identity Card',
    'Driving License',
    'Passport',
  ];

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: 'Verification Document',
      children: [
        Text(
          'Choose the document you want to use for verification.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_options.length, (index) {
          final selected = index == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    index == 0
                        ? Icons.badge_outlined
                        : index == 1
                            ? Icons.drive_eta_outlined
                            : Icons.menu_book_outlined,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _options[index],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(
                    selected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
        PrimaryButton(
          loading: _isSaving,
          label: 'Continue',
          onPressed: () async {
            setState(() => _isSaving = true);
            try {
              await context.read<ApiClient>().dio.put(
                    '/kyc/document',
                    data: {
                      'documentType': _options[_selected],
                      'issuingCountry': 'NG',
                      'documentNumber': '',
                    },
                  );
            } catch (_) {
              // KYC can continue in demo mode when the backend is unavailable.
            } finally {
              if (mounted) {
                setState(() => _isSaving = false);
              }
            }
            if (!mounted) return;
            context.push('/kyc/upload-id');
          },
        ),
      ],
    );
  }
}

class KycUploadIdScreen extends StatefulWidget {
  const KycUploadIdScreen({super.key});

  @override
  State<KycUploadIdScreen> createState() => _KycUploadIdScreenState();
}

class _KycUploadIdScreenState extends State<KycUploadIdScreen> {
  bool _isCreating = false;
  bool _isChecking = false;
  String? _sessionUrl;
  String? _sessionId;
  String? _statusText;

  Future<void> _startStripeVerification() async {
    setState(() => _isCreating = true);
    try {
      final response = await context.read<ApiClient>().dio.post<Map<String, dynamic>>(
            '/kyc/stripe/verification-session',
          );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final url = (data['url'] ?? data['stripeVerificationUrl'] ?? '').toString();
      final sessionId = (data['stripeVerificationId'] ?? '').toString();

      setState(() {
        _sessionUrl = url.isEmpty ? null : url;
        _sessionId = sessionId.isEmpty ? null : sessionId;
        _statusText = 'Stripe session created. Complete the verification and return to the app.';
      });

      if (_sessionUrl != null) {
        final launched = await launchUrl(
          Uri.parse(_sessionUrl!),
          mode: LaunchMode.externalApplication,
        );
        if (!launched && mounted) {
          _showKycMessage(context, 'Unable to open Stripe verification URL automatically.', error: true);
        }
      }
    } catch (error) {
      if (!mounted) return;
      final message = _extractDioMessage(error);
      final status = error is DioException ? error.response?.statusCode : null;
      final isUserMissing = status == 401 ||
          status == 404 ||
          message.toLowerCase().contains('user not found');

      if (isUserMissing) {
        _showKycMessage(context, 'Session expired. Please sign in again.', error: true);
        await context.read<AuthController>().logout();
        if (!mounted) return;
        context.go('/login');
        return;
      }

      final clean = message.endsWith('.') ? message.substring(0, message.length - 1) : message;
      _showKycMessage(
        context,
        '$clean. Tap "Use Demo Verification Flow" to continue offline.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  Future<void> _checkStripeStatus() async {
    if (_sessionId == null || _sessionId!.isEmpty) return;

    setState(() => _isChecking = true);
    try {
      final response = await context.read<ApiClient>().dio.get<Map<String, dynamic>>(
            '/kyc/stripe/verification-session/$_sessionId',
          );
      final data = response.data?['data'] as Map<String, dynamic>? ?? {};
      final kyc = data['kycApplication'] as Map<String, dynamic>? ?? {};
      final stripeSession = data['stripeSession'] as Map<String, dynamic>? ?? {};
      final status = (kyc['status'] ?? '').toString();
      final stripeStatus = (stripeSession['status'] ?? '').toString();

      if (!mounted) return;

      if (status == 'approved' || stripeStatus == 'verified') {
        await context.read<AuthController>().markKycVerified();
        if (!mounted) return;
        context.go('/kyc/verified');
        return;
      }

      if (status == 'resubmission_required') {
        _showKycMessage(
          context,
          (stripeSession['lastError']?['reason'] ?? stripeSession['lastError'] ?? 'Stripe needs more information.')
              .toString(),
          error: true,
        );
        return;
      }

      context.push('/kyc/under-review');
    } catch (error) {
      if (!mounted) return;
      _showKycMessage(context, _extractDioMessage(error), error: true);
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: 'Stripe Identity',
      children: [
        Text(
          'Identity verification will continue securely with Stripe Identity. Stripe will capture your document and matching selfie directly.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
                height: 1.6,
              ),
        ),
        const SizedBox(height: 20),
        const _UploadOptionCard(
          icon: Icons.shield_outlined,
          title: 'Powered by Stripe',
          subtitle: 'Secure hosted identity verification',
        ),
        const SizedBox(height: 14),
        const _UploadOptionCard(
          icon: Icons.credit_card_outlined,
          title: 'Document Capture',
          subtitle: 'Upload the selected document inside Stripe',
        ),
        const SizedBox(height: 14),
        const _UploadOptionCard(
          icon: Icons.face_retouching_natural_outlined,
          title: 'Selfie Match',
          subtitle: 'Stripe will ask for a matching selfie',
        ),
        if (_statusText != null) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.subtle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _statusText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryDark,
                    height: 1.5,
                  ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Continue with Stripe Identity',
          loading: _isCreating,
          onPressed: _startStripeVerification,
        ),
        if (_sessionUrl != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => launchUrl(
                Uri.parse(_sessionUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Open Stripe Verification'),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Check Verification Status',
            loading: _isChecking,
            onPressed: _checkStripeStatus,
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => context.push('/kyc/upload-front'),
            child: const Text('Use Demo Verification Flow'),
          ),
        ),
      ],
    );
  }
}

class KycUploadFrontScreen extends StatefulWidget {
  const KycUploadFrontScreen({super.key});

  @override
  State<KycUploadFrontScreen> createState() => _KycUploadFrontScreenState();
}

class _KycUploadFrontScreenState extends State<KycUploadFrontScreen> {
  bool _hasPreview = false;

  @override
  Widget build(BuildContext context) {
    return _DocumentCaptureScaffold(
      title: 'Upload Front Side',
      description: 'Take a clear photo of the front side of your ID and position it within the frame.',
      previewLabel: 'Front Side Preview',
      hasPreview: _hasPreview,
      onTakePhoto: () => setState(() => _hasPreview = true),
      onUploadGallery: () => setState(() => _hasPreview = true),
      onContinue: () => context.push('/kyc/upload-back'),
    );
  }
}

class KycUploadBackScreen extends StatefulWidget {
  const KycUploadBackScreen({super.key});

  @override
  State<KycUploadBackScreen> createState() => _KycUploadBackScreenState();
}

class _KycUploadBackScreenState extends State<KycUploadBackScreen> {
  bool _hasPreview = false;

  @override
  Widget build(BuildContext context) {
    return _DocumentCaptureScaffold(
      title: 'Upload Back Side',
      description: 'Take a clear photo of the back side of your ID and position it within the frame.',
      previewLabel: 'Back Side Preview',
      hasPreview: _hasPreview,
      onTakePhoto: () => setState(() => _hasPreview = true),
      onUploadGallery: () => setState(() => _hasPreview = true),
      onContinue: () => context.push('/kyc/document-review'),
    );
  }
}

class KycDocumentReviewScreen extends StatelessWidget {
  const KycDocumentReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: 'Document Review',
      children: [
        Text(
          'Review both images before continuing to face verification.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
              ),
        ),
        const SizedBox(height: 20),
        const _DocumentPreviewCard(label: 'Front Side'),
        const SizedBox(height: 14),
        const _DocumentPreviewCard(label: 'Back Side'),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Retake'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Continue',
                onPressed: () => context.push('/kyc/face'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class KycFaceStartScreen extends StatelessWidget {
  const KycFaceStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: 'Face Verification',
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7F3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 180,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: const [
                  _TipChip(label: 'Look Ahead'),
                  _TipChip(label: 'Turn Left'),
                  _TipChip(label: 'Turn Right'),
                  _TipChip(label: 'Blink'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _TipsPanel(
          title: 'Best results',
          items: const [
            'Remove glasses',
            'Use good lighting',
            'No head covering',
          ],
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Take Photo',
          onPressed: () => context.push('/kyc/face/capture'),
        ),
      ],
    );
  }
}

class KycFaceVerificationScreen extends StatefulWidget {
  const KycFaceVerificationScreen({super.key});

  @override
  State<KycFaceVerificationScreen> createState() => _KycFaceVerificationScreenState();
}

class _KycFaceVerificationScreenState extends State<KycFaceVerificationScreen> {
  int _step = 0;

  static const _steps = [
    _FaceStep(progress: 0, instruction: 'Keep your face straight'),
    _FaceStep(progress: 25, instruction: 'Face straight detected'),
    _FaceStep(progress: 50, instruction: 'Turn your head slowly to the right'),
    _FaceStep(progress: 75, instruction: 'Turn your head slowly to the left'),
    _FaceStep(progress: 100, instruction: 'Blink your eyes naturally'),
  ];

  void _next() {
    if (_step == _steps.length - 1) {
      context.go('/kyc/complete');
      return;
    }
    setState(() => _step += 1);
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black87),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        'Face Verification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 220,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(160),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(18),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '${step.progress}%',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            step.instruction,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: step.progress / 100,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8FF0A4)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: step.progress == 100 ? 'Finish' : 'Continue',
                        onPressed: _next,
                      ),
                    ],
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

class KycFaceCompleteScreen extends StatelessWidget {
  const KycFaceCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Face Verification',
      child: Column(
        children: [
          const Spacer(),
          const _BigCheck(),
          const SizedBox(height: 28),
          Text(
            'Face Verification Complete',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This was a demo verification only. To complete real identity verification, return and continue with Stripe Identity.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Back to Stripe Identity',
            onPressed: () => context.go('/kyc/upload-id'),
          ),
        ],
      ),
    );
  }
}

class KycReviewScreen extends StatelessWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Under Review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Verification Status',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Documents uploaded successfully. Review usually takes 5–7 minutes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 28),
          const _ReviewRow(
            title: 'Documents uploaded',
            subtitle: 'Completed',
            status: _ReviewStatus.complete,
          ),
          const _ReviewRow(
            title: 'Face verification completed',
            subtitle: 'Completed',
            status: _ReviewStatus.complete,
          ),
          const _ReviewRow(
            title: 'Admin review in progress',
            subtitle: 'Usually takes 5–7 minutes',
            status: _ReviewStatus.active,
          ),
          const _ReviewRow(
            title: 'Approval & activation',
            subtitle: 'Pending',
            status: _ReviewStatus.pending,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Back to Stripe Identity',
            color: AppColors.warning,
            onPressed: () => context.go('/kyc/upload-id'),
          ),
        ],
      ),
    );
  }
}

class KycVerifiedScreen extends StatelessWidget {
  const KycVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: 'Verification Approved',
      showBack: false,
      child: Column(
        children: [
          const Spacer(),
          const _BigCheck(),
          const SizedBox(height: 28),
          Text(
            'Congratulations!\nYou’re Now Verified.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your account has been approved and your savings tools are now active.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Continue',
            onPressed: () async {
              await context.read<AuthController>().markKycVerified();
              if (!context.mounted) return;
              context.go('/home');
            },
          ),
        ],
      ),
    );
  }
}

class _KycScaffold extends StatelessWidget {
  const _KycScaffold({
    required this.title,
    required this.child,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
            child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 24,
              left: 8,
              right: 8,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showBack)
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  )
                else
                  const SizedBox(width: 48),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _KycFormScaffold extends StatelessWidget {
  const _KycFormScaffold({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _KycScaffold(
      title: title,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _UploadOptionCard extends StatelessWidget {
  const _UploadOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.subtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
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

class _DocumentCaptureScaffold extends StatelessWidget {
  const _DocumentCaptureScaffold({
    required this.title,
    required this.description,
    required this.previewLabel,
    required this.hasPreview,
    required this.onTakePhoto,
    required this.onUploadGallery,
    required this.onContinue,
  });

  final String title;
  final String description;
  final String previewLabel;
  final bool hasPreview;
  final VoidCallback onTakePhoto;
  final VoidCallback onUploadGallery;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _KycFormScaffold(
      title: title,
      children: [
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedText,
                height: 1.6,
              ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.crop_free_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                'Position your ID within the frame',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTakePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onUploadGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Upload'),
              ),
            ),
          ],
        ),
        if (hasPreview) ...[
          const SizedBox(height: 24),
          _DocumentPreviewCard(label: previewLabel),
          const SizedBox(height: 16),
          const _ChecklistTile(label: 'Image is clear'),
          const _ChecklistTile(label: 'No shadows detected'),
          const _ChecklistTile(label: 'No glare detected'),
          const _ChecklistTile(label: 'Text is readable'),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTakePhoto,
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Continue',
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DocumentPreviewCard extends StatelessWidget {
  const _DocumentPreviewCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.image_outlined, color: AppColors.primary, size: 44),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _TipsPanel extends StatelessWidget {
  const _TipsPanel({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(item),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipChip extends StatelessWidget {
  const _TipChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.white,
      label: Text(label),
      side: BorderSide.none,
    );
  }
}

class _BigCheck extends StatelessWidget {
  const _BigCheck();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.subtle.withAlpha(120),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 46),
        ),
      ],
    );
  }
}

enum _ReviewStatus { complete, active, pending }

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final _ReviewStatus status;

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color color;

    switch (status) {
      case _ReviewStatus.complete:
        icon = Icons.check_circle;
        color = AppColors.primary;
        break;
      case _ReviewStatus.active:
        icon = Icons.timelapse_rounded;
        color = AppColors.warning;
        break;
      case _ReviewStatus.pending:
        icon = Icons.radio_button_unchecked;
        color = AppColors.border;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
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

class _FaceStep {
  const _FaceStep({
    required this.progress,
    required this.instruction,
  });

  final int progress;
  final String instruction;
}
