import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/group_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';
import '../auth/auth_controller.dart';
import '../notifications/notifications_controller.dart';
import '../wheel/wheel_controller.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _autoPay = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().load();
      context.read<NotificationsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final homeCtrl = context.watch<HomeController>();
    final unreadCount = context.watch<NotificationsController>().unreadCount;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Ematony';

    final pendingGroups = homeCtrl.pendingPaymentGroups;
    final firstGroup = pendingGroups.isNotEmpty ? pendingGroups.first : null;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<HomeController>().load(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AjoPatternHeader(
                    bottomRadius: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AjoAvatar(
                              name: userName,
                              avatarUrl: user?.avatarUrl,
                              radius: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rise and shine!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFFFCD68D),
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    userName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await context.push('/notifications');
                                if (!context.mounted) return;
                                context.read<NotificationsController>().load();
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFDF5E9),
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: AppColors.text,
                                      size: 22,
                                    ),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: -1,
                                      top: -1,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE53935),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          unreadCount > 99
                                              ? '99+'
                                              : unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Your Balance',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '₦34,671.80',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: const Color(0xFFFDF6EC),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (firstGroup == null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: -120,
                      child: _NoUpcomingPaymentCard(
                        hasGroups: homeCtrl.groups.isNotEmpty,
                      ),
                    )
                  else
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: -120,
                    child: AjoCard(
                      color: const Color(0xFFF9F1DF),
                      borderColor: const Color(0xFFF0E1BE),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Upcoming Payment',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      firstGroup.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            firstGroup.formattedAmount,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Auto Payment :',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 10),
                              _MiniSwitch(
                                value: _autoPay,
                                onChanged: (v) =>
                                    setState(() => _autoPay = v),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: 46,
                                child: FilledButton(
                                  onPressed: () => context.push(
                                    '/groups/${firstGroup.id}',
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Pay Now'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 140),
              // ── Your Active Groups ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Your Active Groups',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/groups'),
                      child: const Text('View all'),
                    ),
                  ],
                ),
              ),
              if (homeCtrl.isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                )
              else if (homeCtrl.groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const AjoCard(
                    radius: 22,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No active groups yet. Create or join one!',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () =>
                        context.push('/groups/${homeCtrl.groups.first.id}'),
                    child: _ActiveGroupCard(
                      group: homeCtrl.groups.first,
                      userName: userName,
                      rotations: homeCtrl.firstGroupRotations,
                      nextWheelDate: homeCtrl.nextWheelDate,
                    ),
                  ),
                ),
              const SizedBox(height: 26),
              // ── Quick Action ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick Action',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.north_east_rounded,
                        iconTint: AppColors.primary,
                        iconBg: AppColors.subtle,
                        label: 'Top Up',
                        onTap: () => context.go('/wallet'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.upload_outlined,
                        iconTint: AppColors.danger,
                        iconBg: AppColors.dangerLight,
                        label: 'Withdraw',
                        onTap: () => context.go('/wallet'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveGroupCard extends StatelessWidget {
  const _ActiveGroupCard({
    required this.group,
    required this.userName,
    required this.rotations,
    required this.nextWheelDate,
  });

  final GroupModel group;
  final String userName;
  final List<WheelRotationItem> rotations;
  final DateTime? nextWheelDate;

  String _formatNextWheel() {
    if (nextWheelDate == null) return '—';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[nextWheelDate!.month - 1]} ${nextWheelDate!.day}';
  }

  @override
  Widget build(BuildContext context) {
    return AjoCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(group.completionPercent * 100).toInt()}%',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rotation : ${group.membersCount} of ${group.maxMembers}',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: group.completionPercent,
              minHeight: 7,
              backgroundColor: const Color(0xFFF5EBD7),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniMemberCluster(
                rotations: rotations,
                totalMembers: group.membersCount,
                fallbackName: userName,
              ),
              const Spacer(),
              Text(
                'Upcoming Wheel : ${_formatNextWheel()}',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconTint,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconTint;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AjoCard(
        radius: 22,
        padding: const EdgeInsets.symmetric(vertical: 22),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconTint, size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFD8DDD4),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF9F1DF),
          ),
        ),
      ),
    );
  }
}

class _MiniMemberCluster extends StatelessWidget {
  const _MiniMemberCluster({
    required this.rotations,
    required this.totalMembers,
    required this.fallbackName,
  });

  final List<WheelRotationItem> rotations;
  final int totalMembers;
  final String fallbackName;

  @override
  Widget build(BuildContext context) {
    final shown = rotations.take(3).toList();
    final remainder = totalMembers - shown.length;
    final hasShown = shown.isNotEmpty;
    final placeholderName = hasShown ? null : fallbackName;
    final stackWidth = (hasShown ? shown.length : 1) * 18.0 + 38;

    return SizedBox(
      width: stackWidth,
      height: 28,
      child: Stack(
        children: [
          if (!hasShown)
            Positioned(
              left: 0,
              child: AjoAvatar(name: placeholderName ?? 'A', radius: 14),
            )
          else
            for (var i = 0; i < shown.length; i++)
              Positioned(
                left: i * 18.0,
                child: AjoAvatar(
                  name: shown[i].name,
                  avatarUrl: shown[i].avatarUrl,
                  radius: 14,
                ),
              ),
          if (remainder > 0)
            Positioned(
              left: (hasShown ? shown.length : 1) * 18.0 + 4,
              top: 4,
              child: Text(
                '+$remainder',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoUpcomingPaymentCard extends StatelessWidget {
  const _NoUpcomingPaymentCard({required this.hasGroups});

  final bool hasGroups;

  @override
  Widget build(BuildContext context) {
    return AjoCard(
      color: const Color(0xFFF9F1DF),
      borderColor: const Color(0xFFF0E1BE),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upcoming Payment',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'No Upcoming Payments',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withAlpha(40),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            hasGroups
                ? "You're all caught up. No pending group payments right now."
                : "You don't have any pending group payments yet.\nCreate or join a group to see upcoming payments here.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              onPressed: () => context.go('/groups'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(hasGroups ? 'View Groups' : 'Create or Join Group'),
            ),
          ),
        ],
      ),
    );
  }
}
