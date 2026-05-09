import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AjoCard extends StatelessWidget {
  const AjoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = 20,
    this.borderColor = AppColors.border,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;
  final Color borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
