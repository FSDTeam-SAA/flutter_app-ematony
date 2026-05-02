import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_assets.dart';
import '../auth/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();

    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final auth = context.read<AuthController>();
      if (auth.isAuthenticated && !auth.isKycVerified) {
        context.go('/kyc');
      } else if (auth.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Top-right African pattern ──
          Positioned(
            top: -10,
            right: -10,
            child: Image.asset(
              AppAssets.patternTopRight,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
          // ── Bottom-left African pattern ──
          Positioned(
            bottom: -10,
            left: -10,
            child: Image.asset(
              AppAssets.patternBottomLeft,
              width: 160,
              height: 160,
              fit: BoxFit.contain,
            ),
          ),
          // ── Centred logo ──
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.logoFlat,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
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
