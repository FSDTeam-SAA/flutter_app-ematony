import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../config/app_assets.dart';
import '../theme/app_colors.dart';

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
      label: 'Wheel',
      icon: Icons.star,
      route: '/wheel',
    ), // Index 2 placeholder
    _NavItemData(
      label: 'Wallet',
      icon: Icons.account_balance_wallet_outlined,
      route: '/wallet',
    ),
    _NavItemData(
      label: 'Profile',
      icon: Icons.person_outline,
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      bottom: false,
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
                height: 84, // Increased height to prevent pixel overflow
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _buildItem(context, 0)),
                    Expanded(child: _buildItem(context, 1)),
                    const SizedBox(
                      width: 80,
                    ), // Responsive space for the middle wheel
                    Expanded(child: _buildItem(context, 3)),
                    Expanded(child: _buildItem(context, 4)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              child: _WheelActionButton(
                isActive: currentIndex == 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(2);
                },
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 170),
                curve: Curves.easeOut,
                width: 46,
                height: 32, // Adjusted height
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: 20, color: foreground),
              ),
              const SizedBox(height: 2), // Adjusted spacing
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11, // Slightly smaller font to prevent overflow
                    height: 1.1,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ),
              const SizedBox(height: 4), // Adjusted spacing
            ],
          ),
        ),
      ),
    );
  }
}

class _WheelActionButton extends StatelessWidget {
  const _WheelActionButton({required this.isActive, required this.onTap});

  final bool isActive;
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
          border: Border.all(
            color: isActive ? AppColors.primaryDark : Colors.white,
            width: 4,
          ),
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
