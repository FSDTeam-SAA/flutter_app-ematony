import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/payment_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';
import 'wallet_controller.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WalletController>();
    final recentTx = ctrl.transactions.take(6).toList();

    final balanceText = _balanceVisible
        ? '₦${ctrl.balance.toStringAsFixed(2).replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}'
        : '₦••••••';

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () => context.read<WalletController>().load(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            children: [
              AjoPatternHeader(
                bottomRadius: 28,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 36),
                      Text(
                        'Your Balance',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      ctrl.isLoading
                          ? const SizedBox(
                              height: 42,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              balanceText,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: const Color(0xFFFDF6EC),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () => setState(
                            () => _balanceVisible = !_balanceVisible),
                        icon: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        label: const Text('View Balance'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withAlpha(90)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Quick Action',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionSquare(
                            icon: Icons.north_east_rounded,
                            iconBg: AppColors.subtle,
                            iconColor: AppColors.primary,
                            label: 'Top Up',
                            onTap: () => _showTopUpSheet(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _ActionSquare(
                            icon: Icons.upload_outlined,
                            iconBg: AppColors.dangerLight,
                            iconColor: AppColors.danger,
                            label: 'Withdraw',
                            onTap: () => _showWithdrawFlow(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Text(
                          'Transactions History',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.push('/transactions'),
                          child: const Text('View all'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (ctrl.isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    else if (recentTx.isEmpty)
                      const AjoCard(
                        radius: 22,
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'No transactions yet.',
                            style: TextStyle(color: AppColors.mutedText),
                          ),
                        ),
                      )
                    else
                      AjoCard(
                        radius: 22,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: recentTx
                              .map((tx) => _TransactionRow(tx: tx))
                              .toList(),
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

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<WalletController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AjoBackHeader(title: 'Transactions History'),
          Expanded(
            child: ctrl.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ctrl.transactions.isEmpty
                    ? Center(
                        child: Text(
                          'No transactions found.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: AjoCard(
                          radius: 20,
                          padding: EdgeInsets.zero,
                          child: ListView.separated(
                            itemCount: ctrl.transactions.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) =>
                                _TransactionRow(
                                    tx: ctrl.transactions[index]),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ActionSquare extends StatelessWidget {
  const _ActionSquare({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
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
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.tx});

  final PaymentModel tx;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tx.isTopUp ? AppColors.subtle : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              tx.isTopUp ? Icons.north_east_rounded : Icons.upload_outlined,
              color: tx.isTopUp ? AppColors.primary : AppColors.danger,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.timeAgo,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: const Color(0xFF9BA3AF)),
                ),
              ],
            ),
          ),
          Text(
            tx.formattedAmount,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.more_vert_rounded, color: AppColors.text),
        ],
      ),
    );
  }
}

Future<void> _showTopUpSheet(BuildContext context) async {
  final amountCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final amount = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Top Up Wallet',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the amount to add to your wallet. Payment is processed securely by Stripe.',
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: amountCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Enter a valid amount';
                  if (value <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(sheetContext).pop(
                        double.parse(amountCtrl.text.trim()),
                      );
                    }
                  },
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  amountCtrl.dispose();
  if (amount == null || !context.mounted) return;

  final ctrl = context.read<WalletController>();
  try {
    final ok = await ctrl.topUp(amount: amount);
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Top-up of \$${amount.toStringAsFixed(2)} successful'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }
}

// ─── Withdraw flow ───────────────────────────────────────────────────────────
//
// Flow:
//   1. Refresh Stripe Connect status from backend.
//   2. If user has not finished onboarding → present onboarding sheet
//      (opens Stripe-hosted URL in external browser; on return, polls
//      `/connect/status` to detect completion).
//   3. If onboarded + payouts enabled → present withdraw amount sheet,
//      submit, refresh transactions.

Future<void> _showWithdrawFlow(BuildContext context) async {
  final ctrl = context.read<WalletController>();
  final messenger = ScaffoldMessenger.of(context);

  Map<String, dynamic> status;
  try {
    status = await ctrl.refreshConnectStatus();
  } catch (e) {
    if (!context.mounted) return;
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    messenger.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
    return;
  }
  if (!context.mounted) return;

  final payoutsEnabled = status['payoutsEnabled'] == true;
  if (!payoutsEnabled) {
    await _showOnboardingSheet(context);
  } else {
    await _showWithdrawAmountSheet(context);
  }
}

Future<void> _showOnboardingSheet(BuildContext context) async {
  final ctrl = context.read<WalletController>();

  // Sheet returns true when status now shows payouts enabled, so the caller
  // knows to open the amount sheet AFTER this one is fully dismissed.
  final shouldOpenAmount = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      bool busy = false;
      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final messenger = ScaffoldMessenger.of(sheetContext);

          Future<void> handleSetup() async {
            setSheetState(() => busy = true);
            try {
              final url = await ctrl.getOnboardingUrl();
              final ok = await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              if (!ok) {
                throw Exception('Could not open the onboarding link');
              }
            } catch (e) {
              final raw = e.toString();
              final msg =
                  raw.startsWith('Exception: ') ? raw.substring(11) : raw;
              messenger.showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
              );
            } finally {
              if (sheetContext.mounted) setSheetState(() => busy = false);
            }
          }

          Future<void> handleCheck() async {
            setSheetState(() => busy = true);
            try {
              final s = await ctrl.refreshConnectStatus();
              if (!sheetContext.mounted) return;
              if (s['payoutsEnabled'] == true) {
                Navigator.of(sheetContext).pop(true);
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Onboarding isn't complete yet. Finish all required steps in the Stripe page.",
                    ),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            } catch (e) {
              final raw = e.toString();
              final msg =
                  raw.startsWith('Exception: ') ? raw.substring(11) : raw;
              messenger.showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
              );
            } finally {
              if (sheetContext.mounted) setSheetState(() => busy = false);
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.subtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Set up Stripe payouts',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Before you can withdraw, Stripe needs your bank or debit-card details. You'll be redirected to a secure Stripe page to complete onboarding.",
                  textAlign: TextAlign.center,
                  style: Theme.of(sheetContext)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.mutedText, height: 1.5),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: busy ? null : handleSetup,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: busy
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Open Stripe Onboarding',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: busy ? null : handleCheck,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("I've finished — check status"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  // The onboarding sheet has fully closed before we get here, so it's safe
  // to open the next sheet without context conflicts.
  if (shouldOpenAmount == true && context.mounted) {
    await _showWithdrawAmountSheet(context);
  }
}

Future<void> _showWithdrawAmountSheet(BuildContext context) async {
  final amountCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final amount = await showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Withdraw to bank',
                style: Theme.of(sheetContext)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Funds are sent to the bank account you connected with Stripe. Payout timing follows your Stripe schedule.',
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: amountCtrl,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null) return 'Enter a valid amount';
                  if (value <= 0) return 'Amount must be greater than zero';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.of(sheetContext).pop(
                        double.parse(amountCtrl.text.trim()),
                      );
                    }
                  },
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  amountCtrl.dispose();
  if (amount == null || !context.mounted) return;

  final ctrl = context.read<WalletController>();
  try {
    await ctrl.withdraw(amount: amount);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Withdrawal of \$${amount.toStringAsFixed(2)} sent'),
        backgroundColor: AppColors.primary,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }
}
