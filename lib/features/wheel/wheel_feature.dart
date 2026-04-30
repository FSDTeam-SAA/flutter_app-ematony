import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../groups/groups_feature.dart';

// ─── Wheel Screen ─────────────────────────────────────────────────────────────

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinCtrl;
  late Animation<double> _spinAnim;
  bool _isSpinning = false;
  int? _winnerIndex;
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _spinAnim = CurvedAnimation(parent: _spinCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsController>().load();
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
    final ctrl = context.read<GroupsController>();
    final members = ctrl.detail?.members ?? [];
    if (members.isEmpty) return;

    setState(() {
      _isSpinning = true;
      _winnerIndex = null;
    });

    _spinCtrl.reset();
    _spinCtrl.forward().then((_) {
      final winner = Random().nextInt(members.length);
      setState(() {
        _isSpinning = false;
        _winnerIndex = winner;
      });

      if (mounted) {
        _showWinnerDialog(context, members[winner].name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();
    final groups = ctrl.groups;
    final detail = ctrl.detail;
    final members = detail?.members ?? [];
    final naira = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Wheel'),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.load,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Group Selector ──
            Text(
              'Select Group',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGroupId,
                  isExpanded: true,
                  hint: const Text('Choose a group'),
                  items: groups.map((g) {
                    return DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name),
                    );
                  }).toList(),
                  onChanged: (id) {
                    setState(() => _selectedGroupId = id);
                    if (id != null) ctrl.loadDetail(id);
                  },
                ),
              ),
            ),

            if (detail != null) ...[
              const SizedBox(height: 16),

              // ── Savings Pool Card ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Savings Pool',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      naira.format(detail.contributionAmount),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _PoolStat(
                          label: 'Next Wheel',
                          value: detail.nextWheelDate.isNotEmpty ? detail.nextWheelDate : 'April-27',
                        ),
                        Container(width: 1, height: 36, color: Colors.white24),
                        _PoolStat(
                          label: 'Members',
                          value: members.length.toString().padLeft(2, '0'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Wheel ──
              Center(
                child: Column(
                  children: [
                    Text(
                      'Next payout (23/03)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _spinAnim,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _spinAnim.value * 6 * pi,
                          child: child,
                        );
                      },
                      child: _WheelWidget(
                        members: members,
                        winnerIndex: _winnerIndex,
                        onSpin: _spin,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Members List ──
              Text(
                'All Members',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...members.asMap().entries.map(
                    (entry) => _MemberRow(
                      index: entry.key,
                      member: entry.value,
                      isWinner: _winnerIndex == entry.key,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  void _showWinnerDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: AppColors.warning, size: 56),
            const SizedBox(height: 16),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'is the winner this round!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Great!'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wheel Widget ─────────────────────────────────────────────────────────────

class _WheelWidget extends StatelessWidget {
  const _WheelWidget({required this.members, this.winnerIndex, required this.onSpin});

  final List<GroupMember> members;
  final int? winnerIndex;
  final VoidCallback onSpin;

  @override
  Widget build(BuildContext context) {
    const size = 280.0;
    final count = members.length.clamp(1, 12);
    final colors = [
      AppColors.primary,
      AppColors.success,
      AppColors.warning,
      AppColors.danger,
      Colors.purple,
      Colors.blue,
    ];

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 8),
              color: AppColors.background,
            ),
          ),
          // Member avatars arranged in a circle
          ...List.generate(count, (i) {
            final angle = (2 * pi * i / count) - (pi / 2);
            const radius = 100.0;
            final x = radius * cos(angle);
            final y = radius * sin(angle);
            final isWinner = winnerIndex == i;
            return Positioned(
              left: size / 2 + x - 24,
              top: size / 2 + y - 24,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[i % colors.length],
                  border: Border.all(
                    color: isWinner ? AppColors.warning : Colors.white,
                    width: isWinner ? 3 : 2,
                  ),
                  boxShadow: isWinner
                      ? [const BoxShadow(color: AppColors.warning, blurRadius: 8)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    members[i].name.isNotEmpty ? members[i].name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          }),
          // Center spin button
          GestureDetector(
            onTap: onSpin,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'Spin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _PoolStat extends StatelessWidget {
  const _PoolStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.index,
    required this.member,
    required this.isWinner,
  });

  final int index;
  final GroupMember member;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner ? AppColors.subtle : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isWinner ? AppColors.primary : AppColors.background,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isWinner ? Colors.white : AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.subtle,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
          if (isWinner) ...[
            const Icon(Icons.emoji_events, color: AppColors.warning, size: 18),
            const SizedBox(width: 4),
            Text(
              'Last Winner',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Pending',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
