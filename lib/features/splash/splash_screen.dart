import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _CornerDecoration(size: 220, alignment: Alignment.topRight),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _CornerDecoration(size: 220, alignment: Alignment.bottomLeft),
          ),
          Center(
            child: Image.asset(
              'assets/ajo-family.png',
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({required this.size, required this.alignment});

  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        gradient: const SweepGradient(
          colors: [
            Color(0xFF1A6B5A),
            Color(0xFFE88C24),
            Color(0xFF1A6B5A),
            Color(0xFFE24B4A),
            Color(0xFF1A6B5A),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(180),
          borderRadius: BorderRadius.circular(size / 2),
        ),
      ),
    );
  }
}
