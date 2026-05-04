import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';

class WheelScreen extends StatelessWidget {
  const WheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Until real group members exist, render placeholder slots.
    const List<String> members = <String>[];
    const slotCount = 8;

    return AjoScaffold(
      currentIndex: -1,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AjoPatternHeader(
                    height: 298,
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
                        Container(
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
                                  'Friends With Benefits - 2026',
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
                            '\u20A61000.00',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(
                                child: _PoolMeta(label: 'Next Wheel', value: 'April -27'),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _PoolMeta(label: 'Members', value: '08'),
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
                      'Next payout (23/03)',
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
                      onTap: () => context.push('/wheel/winner?name=Ematony&amount=%E2%82%A612000'),
                      child: _WheelDisc(
                        names: members,
                        slotCount: slotCount,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                    if (members.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No members yet. Invite people to fill the wheel.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      )
                    else
                      ...List.generate(
                        members.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _WheelMemberRow(
                            index: index + 1,
                            name: members[index],
                            winner: index == 0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    required this.names,
    this.slotCount = 8,
  });

  final List<String> names;
  final int slotCount;

  @override
  Widget build(BuildContext context) {
    final count = names.isEmpty ? slotCount : names.length;
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
              left: 165 + 120 * math.cos((2 * math.pi * i / count) - math.pi / 2) - 28,
              top: 165 + 120 * math.sin((2 * math.pi * i / count) - math.pi / 2) - 28,
              child: i < names.length
                  ? AjoAvatar(name: names[i], radius: 28)
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
    required this.winner,
  });

  final int index;
  final String name;
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
          AjoAvatar(name: name, radius: 14),
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
                winner ? Icons.workspace_premium_outlined : Icons.timelapse_outlined,
                color: const Color(0xFFF4AF21),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                winner ? 'Last Winner' : 'Pending',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: winner ? const Color(0xFFF6F6D5) : const Color(0xFFF4AF21),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
