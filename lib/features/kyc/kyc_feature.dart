import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

// ─── Identity Verification Intro ─────────────────────────────────────────────

class IdentityVerificationScreen extends StatelessWidget {
  const IdentityVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Identity Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.subtle,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Identity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'For security and compliance, Ematony requires identity verification before joining savings groups.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/kyc/personal-info'),
                  child: const Text('Start Verification'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Personal Info Screen ─────────────────────────────────────────────────────

class KycPersonalInfoScreen extends StatefulWidget {
  const KycPersonalInfoScreen({super.key});

  @override
  State<KycPersonalInfoScreen> createState() => _KycPersonalInfoScreenState();
}

class _KycPersonalInfoScreenState extends State<KycPersonalInfoScreen> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Personal Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KycField(label: 'Full Name', controller: _nameCtrl, hint: 'Enter Your Name'),
              const SizedBox(height: 16),
              _KycField(
                label: 'Date of Birth',
                controller: _dobCtrl,
                hint: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              _KycField(
                label: 'Email',
                controller: _emailCtrl,
                hint: 'Enter Your Email Address',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _KycField(
                label: 'Phone Number',
                controller: _phoneCtrl,
                hint: 'Enter Your Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _KycField(
                label: 'Address',
                controller: _addressCtrl,
                hint: 'Street, City, Postcode',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/kyc/document'),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Verification Document Screen ─────────────────────────────────────────────

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  int _selected = 0;

  static const _docs = [
    _DocOption(icon: Icons.credit_card_outlined, label: 'Identity Card'),
    _DocOption(icon: Icons.drive_eta_outlined, label: 'Driving licence'),
    _DocOption(icon: Icons.book_outlined, label: 'Passport'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Verification Document'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Your Verification Document',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
              ),
              const SizedBox(height: 20),
              ...List.generate(_docs.length, (i) {
                final doc = _docs[i];
                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selected == i ? AppColors.primary : AppColors.border,
                        width: _selected == i ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(doc.icon, color: AppColors.text, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            doc.label,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        if (_selected == i)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 12),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/kyc/upload-id'),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocOption {
  const _DocOption({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// ─── Upload ID Screen ─────────────────────────────────────────────────────────

class KycUploadIdScreen extends StatefulWidget {
  const KycUploadIdScreen({super.key});

  @override
  State<KycUploadIdScreen> createState() => _KycUploadIdScreenState();
}

class _KycUploadIdScreenState extends State<KycUploadIdScreen> {
  bool _frontDone = false;
  bool _backDone = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Upload Your ID'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Upload Your Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),
              _UploadTile(
                label: 'Upload Front Side',
                done: _frontDone,
                onTap: () => _showPickerSheet(context, isFront: true),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
              ),
              _UploadTile(
                label: 'Upload Back Side',
                done: _backDone,
                onTap: () => _showPickerSheet(context, isFront: false),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_frontDone && _backDone)
                      ? () => context.push('/kyc/face')
                      : null,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPickerSheet(BuildContext context, {required bool isFront}) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Select documents from your gallery or take\nnew ones with your camera.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => isFront ? _frontDone = true : _backDone = true);
              },
              child: const Text('Camera'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => isFront ? _frontDone = true : _backDone = true);
              },
              child: const Text('Gallery'),
            ),
            const SizedBox(height: 10),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({required this.label, required this.done, required this.onTap});

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: done ? AppColors.subtle : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle_outline : Icons.upload_outlined,
              color: done ? AppColors.primary : AppColors.mutedText,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: done ? AppColors.primary : AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Face Verification Screen ─────────────────────────────────────────────────

class KycFaceVerificationScreen extends StatefulWidget {
  const KycFaceVerificationScreen({super.key});

  @override
  State<KycFaceVerificationScreen> createState() => _KycFaceVerificationScreenState();
}

class _KycFaceVerificationScreenState extends State<KycFaceVerificationScreen> {
  int _step = 0;
  double _progress = 0;

  static const _prompts = [
    'Keep Your Face Straight',
    'Turn your head slowly to the right',
    'Turn your head slowly to the left',
    'Blink your eyes naturally',
  ];

  static const _stepPercents = [0.0, 0.25, 0.5, 0.75, 1.0];

  void _nextStep() {
    if (_step < _prompts.length - 1) {
      setState(() {
        _step++;
        _progress = _stepPercents[_step];
      });
    } else {
      setState(() => _progress = 1.0);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.push('/kyc/complete');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Face Verification', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.grey[900]),
          Center(
            child: Container(
              width: 240,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 2),
                borderRadius: BorderRadius.circular(120),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
              ),
              child: Column(
                children: [
                  Text(
                    _prompts[_step],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progress == 1.0 ? Colors.green : Colors.greenAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextStep,
                      child: Text(_step < _prompts.length - 1 ? 'Next' : 'Complete'),
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

// ─── Face Verification Complete ───────────────────────────────────────────────

class KycFaceCompleteScreen extends StatelessWidget {
  const KycFaceCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Face Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _CircleCheck(size: 120, iconSize: 56),
              const SizedBox(height: 28),
              Text(
                'Face Verification Complete',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'By submitting, you confirm that all information provided is accurate and you agree to our terms of service and privacy policy.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.push('/kyc/review'),
                  child: const Text('Submit Verification'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Under Review Screen ──────────────────────────────────────────────────────

class KycReviewScreen extends StatelessWidget {
  const KycReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        title: const Text('Under Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                'Verification\nUnder Review',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your identity is under review. You\'ll be notified once approved.\nUsually takes 5-10 minutes',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _ReviewStep(
                label: 'Documents uploaded',
                status: _StepStatus.done,
              ),
              _ReviewStep(
                label: 'Face verification completed',
                status: _StepStatus.done,
              ),
              _ReviewStep(
                label: 'Admin review in progress',
                status: _StepStatus.active,
              ),
              _ReviewStep(
                label: 'Approval & activation',
                status: _StepStatus.pending,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.warning,
                  ),
                  onPressed: () {},
                  child: const Text('Waiting For Approval'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StepStatus { done, active, pending }

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.label, required this.status});

  final String label;
  final _StepStatus status;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final IconData icon;

    switch (status) {
      case _StepStatus.done:
        iconColor = AppColors.primary;
        icon = Icons.check_circle;
        break;
      case _StepStatus.active:
        iconColor = AppColors.warning;
        icon = Icons.radio_button_checked;
        break;
      case _StepStatus.pending:
        iconColor = AppColors.border;
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: status == _StepStatus.pending ? AppColors.mutedText : AppColors.text,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Verified Screen ──────────────────────────────────────────────────────────

class KycVerifiedScreen extends StatelessWidget {
  const KycVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              _CircleCheck(size: 120, iconSize: 56),
              const SizedBox(height: 28),
              Text(
                'Congratulations!\nYou\'re Now Verified.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You are now a verified user.\nYour documents have been reviewed and approved.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _CircleCheck extends StatelessWidget {
  const _CircleCheck({required this.size, required this.iconSize});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.subtle.withAlpha(120),
          ),
        ),
        Container(
          width: size * 0.75,
          height: size * 0.75,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.subtle,
          ),
        ),
        Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          child: Icon(Icons.check, color: Colors.white, size: iconSize),
        ),
      ],
    );
  }
}

class _KycField extends StatelessWidget {
  const _KycField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
