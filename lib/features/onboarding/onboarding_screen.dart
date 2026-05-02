import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_assets.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      image: AppAssets.onboarding1,
      title: 'Save Together. Win Together.',
      body: 'Join your trusted circle of friends, colleagues, or '
          'family members in a rotating savings group.',
      showSkip: false,
    ),
    _PageData(
      image: AppAssets.onboarding2,
      title: 'Grow Your Savings. Earn More.',
      body: 'Save collectively toward shared goals and earn 7% '
          'interest at year-end.',
      showSkip: true,
    ),
    _PageData(
      image: AppAssets.onboarding3,
      title: 'Build Your Future, One Project At A Time.',
      body: 'Turn ideas into reality through group investments in '
          'meaningful projects — schools, hospitals, markets, or '
          'production hubs.',
      showSkip: false,
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  void _next() {
    if (_isLast) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _skipToLast() {
    _controller.animateToPage(
      _pages.length - 1,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => setState(() => _page = i),
        itemCount: _pages.length,
        itemBuilder: (context, i) => _isLast
            ? _LastPage(data: _pages[i], currentPage: _page)
            : _RegularPage(
                data: _pages[i],
                currentPage: _page,
                onNext: _next,
                onSkip: _skipToLast,
              ),
      ),
    );
  }
}

// ─── Regular page (index 0 & 1) ──────────────────────────────────────────────

class _RegularPage extends StatelessWidget {
  const _RegularPage({
    required this.data,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  final _PageData data;
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Column(
      children: [
        // ── Hero image (top half) ──
        Expanded(
          flex: 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                data.image,
                fit: BoxFit.cover,
              ),
              // Skip button — only on page with showSkip=true
              if (data.showSkip)
                Positioned(
                  top: topPadding + 14,
                  right: 20,
                  child: GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Content area (bottom half) ──
        Expanded(
          flex: 10,
          child: Container(
            color: AppColors.background,
            child: Stack(
              children: [
                // Text content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 80, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        data.body,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                      const Spacer(),
                      // Dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: _Dots(current: currentPage),
                      ),
                    ],
                  ),
                ),

                // Pattern wheel button — bottom right, partially off-screen
                Positioned(
                  bottom: -28,
                  right: -28,
                  child: GestureDetector(
                    onTap: onNext,
                    child: SizedBox(
                      width: 148,
                      height: 148,
                      child: Image.asset(
                        AppAssets.wheelSpinner,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Last page (index 2) ─────────────────────────────────────────────────────

class _LastPage extends StatelessWidget {
  const _LastPage({required this.data, required this.currentPage});

  final _PageData data;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Hero image ──
        Expanded(
          flex: 10,
          child: Image.asset(
            data.image,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        // ── Content ──
        Expanded(
          flex: 10,
          child: Container(
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        data.body,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Dark curved footer
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(280, 56),
                    ),
                  ),
                  padding:
                      const EdgeInsets.fromLTRB(24, 26, 24, 18),
                  child: Column(
                    children: [
                      // Dots (white on dark bg)
                      _Dots(current: currentPage, onDark: true),
                      const SizedBox(height: 20),

                      // Get Started
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: () => context.go('/signup'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1F7867),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 20, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Log in
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withAlpha(100)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Dots indicator ───────────────────────────────────────────────────────────

class _Dots extends StatelessWidget {
  const _Dots({required this.current, this.onDark = false});

  final int current;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: active ? 28 : 10,
          height: 10,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: active
                ? (onDark ? Colors.white : AppColors.primaryDark)
                : (onDark
                    ? Colors.white.withAlpha(60)
                    : AppColors.primaryDark.withAlpha(40)),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _PageData {
  const _PageData({
    required this.image,
    required this.title,
    required this.body,
    required this.showSkip,
  });

  final String image;
  final String title;
  final String body;
  final bool showSkip;
}
