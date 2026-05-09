import 'package:flutter/material.dart';

import '../../core/config/app_assets.dart';

/// Shows a branded splash while [AuthController.bootstrap] completes.
/// 
/// IMPORTANT: This widget does NO navigation. 
/// GoRouter's `refreshListenable` in [AppRouter] detects when 
/// [AuthController.isReady] becomes true and performs the redirect 
/// to /home or /onboarding automatically.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _animCtrl.forward();
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
          // ── Decorative top-right pattern ──
          Positioned(
            top: -20,
            right: -20,
            child: Image.asset(
              AppAssets.patternTopRight,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              cacheWidth: 360, // Optimize memory
            ),
          ),
          // ── Decorative bottom-left pattern ──
          Positioned(
            bottom: -20,
            left: -20,
            child: Image.asset(
              AppAssets.patternBottomLeft,
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              cacheWidth: 360, // Optimize memory
            ),
          ),
          // ── Animated centered logo ──
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Image.asset(
                  AppAssets.logoFlat,
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  cacheWidth: 440, // Optimize memory
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
