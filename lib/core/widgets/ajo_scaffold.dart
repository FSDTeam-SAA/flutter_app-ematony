import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'ajo_bottom_nav.dart';

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
                const routes = ['/home', '/groups', '/wheel', '/wallet', '/profile'];
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
