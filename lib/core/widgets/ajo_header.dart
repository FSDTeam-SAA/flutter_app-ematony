import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class AjoPatternHeader extends StatelessWidget {
  const AjoPatternHeader({
    super.key,
    required this.child,
    this.height,
    this.bottomRadius = 30,
    this.padding,
  });

  final Widget child;
  final double? height;
  final double bottomRadius;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(bottomRadius),
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _HeaderPatternPainter()),
            ),
            Padding(
              padding:
                  padding ??
                  EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 12,
                    16,
                    20,
                  ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class AjoBackHeader extends StatelessWidget {
  const AjoBackHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AjoPatternHeader(
      height: MediaQuery.of(context).padding.top + 96,
      bottomRadius: 22,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withAlpha(22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;

    final pathA =
        Path()
          ..moveTo(-size.width * 0.08, size.height * 0.76)
          ..quadraticBezierTo(
            size.width * 0.18,
            size.height * 0.42,
            size.width * 0.55,
            size.height * 0.54,
          )
          ..quadraticBezierTo(
            size.width * 0.83,
            size.height * 0.63,
            size.width * 1.08,
            size.height * 0.46,
          );
    final pathB =
        Path()
          ..moveTo(size.width * 0.12, size.height * 1.02)
          ..quadraticBezierTo(
            size.width * 0.08,
            size.height * 0.56,
            size.width * 0.50,
            size.height * 0.28,
          )
          ..quadraticBezierTo(
            size.width * 0.78,
            size.height * 0.10,
            size.width * 1.02,
            size.height * 0.30,
          );
    final pathC =
        Path()
          ..moveTo(size.width * 0.02, size.height * 0.22)
          ..quadraticBezierTo(
            size.width * 0.38,
            size.height * 0.78,
            size.width * 0.98,
            size.height * 0.74,
          );

    canvas.drawPath(pathA, paint);
    canvas.drawPath(pathB, paint);
    canvas.drawPath(pathC, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
