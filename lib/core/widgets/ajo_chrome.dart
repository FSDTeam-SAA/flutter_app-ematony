import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../config/app_assets.dart';
import '../theme/app_colors.dart';

class AjoScaffold extends StatelessWidget {
  const AjoScaffold({
    super.key,
    this.currentIndex = 0,
    required this.body,
    this.bottomNav = true,
  });

  final int currentIndex;
  final Widget body;
  final bool bottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
      bottomNavigationBar: bottomNav
          ? AjoBottomNav(
              currentIndex: currentIndex,
              onTap: (i) {
                HapticFeedback.selectionClick();
                const routes = ['/home', '/groups', '/wallet', '/profile'];
                if (i < routes.length) context.go(routes[i]);
              },
            )
          : null,
    );
  }
}

/// Persistent shell scaffold used by [StatefulShellRoute].
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: AjoBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// Custom [StatefulShellRoute] navigator container with fade-in on tab switch.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
      value: 1.0,
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(AnimatedBranchContainer old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex) {
      _ctrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(widget.children.length, (i) {
        final active = i == widget.currentIndex;
        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: FadeTransition(
              opacity: active ? _fade : const AlwaysStoppedAnimation(1.0),
              child: widget.children[i],
            ),
          ),
        );
      }),
    );
  }
}

class AjoBottomNav extends StatelessWidget {
  const AjoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(label: 'Home', icon: Icons.home_outlined, route: '/home'),
    _NavItemData(
      label: 'Group',
      icon: Icons.blur_circular_outlined,
      route: '/groups',
    ),
    _NavItemData(
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      route: '/wallet',
    ),
    _NavItemData(label: 'Profile', icon: Icons.person_outline, route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 120 + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              left: 16,
              right: 16,
              bottom: 12 + bottomInset,
              child: Container(
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD9E5DF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(14),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildItem(context, 0)),
                    Expanded(child: _buildItem(context, 1)),
                    const SizedBox(width: 88),
                    Expanded(child: _buildItem(context, 2)),
                    Expanded(child: _buildItem(context, 3)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _WheelActionButton(onTap: () => context.go('/wheel')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final isActive = currentIndex == index;
    final foreground = isActive ? Colors.white : const Color(0xFF205446);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (!isActive) onTap(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                width: 46,
                height: 34,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 20, color: foreground),
              ),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: foreground,
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelActionButton extends StatelessWidget {
  const _WheelActionButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFEAF4EF),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(24),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: ClipOval(
            child: Image.asset(AppAssets.spinIcon2, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class AjoPatternHeader extends StatelessWidget {
  const AjoPatternHeader({
    super.key,
    required this.child,
    this.height = 250,
    this.bottomRadius = 30,
    this.padding,
  });

  final Widget child;
  final double height;
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

class AjoAvatar extends StatelessWidget {
  const AjoAvatar({super.key, required this.name, this.radius = 22});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts
        .take(2)
        .map((part) => part.isEmpty ? '' : part[0])
        .join()
        .toUpperCase();

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFD8E8DF), Color(0xFF7DA892)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'AF' : initials,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: radius * 0.52,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
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
