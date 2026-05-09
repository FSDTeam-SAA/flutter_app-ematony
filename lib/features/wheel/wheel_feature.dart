import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';
import 'wheel_controller.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_bootstrapped) {
      _bootstrapped = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<WheelController>().loadGroups();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WheelController>(
      builder: (context, controller, _) {
        return SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () => controller.loadGroups(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 110),
              child: _buildBody(context, controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WheelController controller) {
    final selected = controller.selectedGroup;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AjoPatternHeader(
              bottomRadius: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Text(
                    'Select Group',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _GroupDropdown(controller: controller),
                  const SizedBox(height: 90),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: -56,
              child: AjoCard(
                color: AppColors.primaryDark,
                radius: 22,
                borderColor: const Color(0xFF8DA398),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
                child: Column(
                  children: [
                    Text(
                      'Current Savings Pool',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selected != null
                          ? controller.formattedSavingsPool()
                          : '₦0.00',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _PoolMeta(
                            label: 'Next Wheel',
                            value: _nextWheelLabel(controller),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PoolMeta(
                            label: 'Members',
                            value: controller.totalMembers
                                .toString()
                                .padLeft(2, '0'),
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
        const SizedBox(height: 88),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                'Next payout (${_nextPayoutShort(controller)})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _onWheelTap(context, controller),
                child: _WheelDisc(
                  rotations: controller.rotations,
                  slotCount: selected?.maxMembers.clamp(3, 10) ?? 8,
                ),
              ),
              const SizedBox(height: 24),
              if (controller.isLoadingWheel)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Members',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              if (controller.isLoadingGroups && controller.groups.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.groups.isEmpty)
                _emptyState(
                  context,
                  controller.error ??
                      'No groups yet. Create or join a group to start spinning.',
                )
              else if (controller.rotations.isEmpty)
                _emptyState(
                  context,
                  'No members yet. Invite people to fill the wheel.',
                )
              else
                ...List.generate(controller.rotations.length, (index) {
                  final item = controller.rotations[index];
                  final isWinner =
                      controller.lastWinner?.userId == item.userId &&
                          item.userId.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _WheelMemberRow(
                      index: item.positionNumber > 0
                          ? item.positionNumber
                          : index + 1,
                      name: item.name,
                      avatarUrl: item.avatarUrl,
                      winner: isWinner,
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  void _onWheelTap(BuildContext context, WheelController controller) async {
    if (controller.canSpin) {
      final result = await controller.spin();
      if (!context.mounted) return;
      if (result != null) {
        final winnerName = (result['winnerUser'] is Map)
            ? ((result['winnerUser'] as Map)['name']?.toString() ?? 'Winner')
            : 'Winner';
        final amount = (result['amount'] as num?)?.toString() ?? '0';
        context.push(
          '/wheel/winner?name=${Uri.encodeComponent(winnerName)}&amount=${Uri.encodeComponent('₦$amount')}',
        );
      } else if (controller.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.error!)),
        );
      }
    } else if (controller.lastWinner != null) {
      final name = controller.lastWinner!.name;
      final amount = controller.formattedSavingsPool();
      context.push(
        '/wheel/winner?name=${Uri.encodeComponent(name)}&amount=${Uri.encodeComponent(amount)}',
      );
    } else if (controller.spinWindow['startDay'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Wheel can be spun between day ${controller.spinWindow['startDay']} and ${controller.spinWindow['endDay']}.',
          ),
        ),
      );
    }
  }

  Widget _emptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.mutedText,
            ),
      ),
    );
  }

  String _nextWheelLabel(WheelController controller) {
    final startDay = (controller.spinWindow['startDay'] as num?)?.toInt() ?? 25;
    final today = (controller.spinWindow['today'] as num?)?.toInt() ??
        DateTime.now().day;
    final now = DateTime.now();
    final useNextMonth = today > startDay;
    final target = useNextMonth
        ? DateTime(now.year, now.month + 1, startDay)
        : DateTime(now.year, now.month, startDay);
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[target.month - 1]} -${target.day}';
  }

  String _nextPayoutShort(WheelController controller) {
    final endDay = (controller.spinWindow['endDay'] as num?)?.toInt() ?? 30;
    final today = (controller.spinWindow['today'] as num?)?.toInt() ??
        DateTime.now().day;
    final now = DateTime.now();
    final target = today > endDay
        ? DateTime(now.year, now.month + 1, endDay)
        : DateTime(now.year, now.month, endDay);
    final dd = target.day.toString().padLeft(2, '0');
    final mm = target.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}

class _GroupDropdown extends StatelessWidget {
  const _GroupDropdown({required this.controller});

  final WheelController controller;

  @override
  Widget build(BuildContext context) {
    final selected = controller.selectedGroup;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: controller.groups.isEmpty
          ? null
          : () => _openPicker(context, controller),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(80)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white),
              ),
              child: const Icon(
                Icons.blur_circular_outlined,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected?.name ??
                    (controller.isLoadingGroups
                        ? 'Loading groups…'
                        : 'No groups available'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, WheelController controller) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Select Group',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                ...controller.groups.map(
                  (g) => ListTile(
                    leading: const Icon(
                      Icons.blur_circular_outlined,
                      color: AppColors.primaryDark,
                    ),
                    title: Text(g.name),
                    trailing: controller.selectedGroup?.id == g.id
                        ? const Icon(Icons.check, color: AppColors.primaryDark)
                        : null,
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      controller.selectGroup(g);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class WinnerCongratulationsScreen extends StatelessWidget {
  const WinnerCongratulationsScreen({
    super.key,
    required this.winnerName,
    required this.amount,
  });

  final String winnerName;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 34),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AjoAvatar(name: winnerName, radius: 42),
                      Positioned(
                        right: -2,
                        bottom: 4,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2F7F57),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Congratulations',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFFFF7A1A),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    winnerName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 180,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      amount,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'You receive $amount\nthis month.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 26),
                  TextButton(
                    onPressed: () => context.go('/groups'),
                    child: const Text('Back to Groups'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PoolMeta extends StatelessWidget {
  const _PoolMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _WheelDisc extends StatelessWidget {
  const _WheelDisc({
    required this.rotations,
    this.slotCount = 8,
  });

  final List<WheelRotationItem> rotations;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final count = rotations.isEmpty ? slotCount : rotations.length;
    return SizedBox(
      width: 330,
      height: 330,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 330,
            height: 330,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF4AF21), width: 2),
              gradient: const RadialGradient(
                colors: [Color(0xFF0D5544), AppColors.primaryDark],
              ),
            ),
          ),
          for (var i = 0; i < count; i++)
            Positioned(
              left: 165 +
                  120 * math.cos((2 * math.pi * i / count) - math.pi / 2) -
                  28,
              top: 165 +
                  120 * math.sin((2 * math.pi * i / count) - math.pi / 2) -
                  28,
              child: i < rotations.length
                  ? AjoAvatar(
                      name: rotations[i].name,
                      avatarUrl: rotations[i].avatarUrl,
                      radius: 28,
                    )
                  : const _WheelSlotPlaceholder(),
            ),
          Container(
            width: 126,
            height: 126,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryDark,
              border: Border.all(color: const Color(0xFFF4AF21), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              'Spin',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelSlotPlaceholder extends StatelessWidget {
  const _WheelSlotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(40),
        border: Border.all(color: Colors.white.withAlpha(140), width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        color: Colors.white.withAlpha(220),
        size: 28,
      ),
    );
  }
}

class _WheelMemberRow extends StatelessWidget {
  const _WheelMemberRow({
    required this.index,
    required this.name,
    required this.avatarUrl,
    required this.winner,
  });

  final int index;
  final String name;
  final String? avatarUrl;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: winner ? const Color(0xFF1F6F5D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF4AF21)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF4AF21)),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                color: winner ? Colors.white : AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AjoAvatar(name: name, avatarUrl: avatarUrl, radius: 14),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 15,
                    color: winner ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Row(
            children: [
              Icon(
                winner
                    ? Icons.workspace_premium_outlined
                    : Icons.timelapse_outlined,
                color: const Color(0xFFF4AF21),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                winner ? 'Last Winner' : 'Pending',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: winner
                          ? const Color(0xFFF6F6D5)
                          : const Color(0xFFF4AF21),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
