import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _NavItemData(label: 'Home', icon: Icons.home_outlined),
    _NavItemData(label: 'Group', icon: Icons.blur_circular_outlined),
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
          // "Next payout" indicator above the nav bar
          Positioned(
            bottom: 104 + bottomInset,
            child: Column(
              children: [
                const Text(
                  'Next payout (23/03)',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(Icons.arrow_drop_down, color: AppColors.primaryDark, size: 20),
              ],
            ),
          ),

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

class _SpinActionButton extends StatelessWidget {
  const _SpinActionButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: isActive ? AppColors.primaryDark : Colors.white,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Member collage background (placeholder with image)
              ClipOval(
                child: Image.asset(
                  AppAssets.spinIcon2,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // "Spin" text in center
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: const Text(
                  'Spin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  });

  final String label;
  final IconData icon;
}
