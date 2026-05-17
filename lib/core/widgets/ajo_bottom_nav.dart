import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../../features/wheel/wheel_controller.dart';
import 'ajo_avatar.dart';

class AjoBottomNav extends StatelessWidget {
  const AjoBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(label: 'Home', icon: Icons.home_outlined),
    _NavItemData(label: 'Group', icon: Icons.groups_2_outlined),
    _NavItemData(label: 'Spin', icon: Icons.star), // Index 2 placeholder
    _NavItemData(label: 'Wallet', icon: Icons.account_balance_wallet_outlined),
    _NavItemData(label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      height: 140 + bottomInset,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Main Navigation Bar Container
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildItem(context, 0)),
                  Expanded(child: _buildItem(context, 1)),
                  const SizedBox(width: 80), // Space for the Spin button
                  Expanded(child: _buildItem(context, 3)),
                  Expanded(child: _buildItem(context, 4)),
                ],
              ),
            ),
          ),

          // Prominent "Spin" Action Button
          Positioned(
            bottom: 44 + bottomInset,
            child: _SpinActionButton(
              isActive: currentIndex == 2,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final isActive = currentIndex == index;
    final color = isActive ? Colors.white : AppColors.primaryDark;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryDark : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
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

class _SpinActionButton extends StatefulWidget {
  const _SpinActionButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_SpinActionButton> createState() => _SpinActionButtonState();
}

class _SpinActionButtonState extends State<_SpinActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final wheelController = context.watch<WheelController>();
    if (!wheelController.isLoadingGroups &&
        wheelController.groups.isEmpty &&
        wheelController.rotations.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<WheelController>().loadGroups();
        }
      });
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 1.06 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 102,
          height: 102,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(_pressed ? 45 : 28),
                blurRadius: _pressed ? 22 : 16,
                offset: Offset(0, _pressed ? 12 : 8),
              ),
            ],
          ),
          child: _MiniWheelButton(
            isActive: widget.isActive,
            rotations: wheelController.rotations,
          ),
        ),
      ),
    );
  }
}

class _MiniWheelButton extends StatelessWidget {
  const _MiniWheelButton({
    required this.isActive,
    required this.rotations,
  });

  final bool isActive;
  final List<WheelRotationItem> rotations;

  @override
  Widget build(BuildContext context) {
    final visibleMembers = rotations.take(8).toList();
    final memberCount = visibleMembers.length;
    final slotCount = memberCount == 0 ? 0 : memberCount;
    const discSize = 96.0;
    const center = discSize / 2;
    final orbitRadius = memberCount <= 4 ? 34.0 : 35.5;
    final avatarRadius = memberCount <= 4 ? 11.0 : 9.5;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: discSize,
          height: discSize,
          child: CustomPaint(
            painter: _MiniWheelPainter(
              active: isActive,
              segmentCount: math.max(memberCount, 6),
            ),
          ),
        ),
        for (var i = 0; i < slotCount; i++)
          Positioned(
            left:
                center +
                orbitRadius *
                    math.cos((2 * math.pi * i / slotCount) - math.pi / 2) -
                avatarRadius,
            top:
                center +
                orbitRadius *
                    math.sin((2 * math.pi * i / slotCount) - math.pi / 2) -
                avatarRadius,
            child: AjoAvatar(
              name: visibleMembers[i].name,
              avatarUrl: visibleMembers[i].avatarUrl,
              radius: avatarRadius,
            ),
          ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryDark,
            border: Border.all(color: const Color(0xFFF4AF21), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Spin',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
          ),
        ),
      ],
    );
  }
}

class _MiniWheelPainter extends CustomPainter {
  _MiniWheelPainter({
    required this.active,
    required this.segmentCount,
  });

  final bool active;
  final int segmentCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 1);
    final colors = <Color>[
      const Color(0xFF0A4F40),
      const Color(0xFF0D5A49),
      const Color(0xFF0B5344),
      const Color(0xFF126650),
    ];
    final dividerPaint =
        Paint()
          ..color = const Color(0xFFF4AF21).withAlpha(active ? 220 : 175)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

    for (var i = 0; i < segmentCount; i++) {
      final startAngle = (-math.pi / 2) + (2 * math.pi * i / segmentCount);
      final sweep = (2 * math.pi / segmentCount);
      final fill =
          Paint()
            ..color = colors[i % colors.length]
            ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweep, true, fill);
    }

    for (var i = 0; i < segmentCount; i++) {
      final angle = (-math.pi / 2) + (2 * math.pi * i / segmentCount);
      final point = Offset(
        center.dx + (radius - 2) * math.cos(angle),
        center.dy + (radius - 2) * math.sin(angle),
      );
      canvas.drawLine(center, point, dividerPaint);
    }

    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = const Color(0xFF0C5848)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..color = AppColors.primaryDark
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(center, 18, dividerPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniWheelPainter oldDelegate) {
    return oldDelegate.active != active ||
        oldDelegate.segmentCount != segmentCount;
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
