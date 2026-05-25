import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

// ─── Top-up flow ─────────────────────────────────────────────────────────────
//
// 1. User enters amount + currency in a bottom sheet.
// 2. Backend creates a Flutterwave hosted-checkout link, returns `{ paymentLink, txRef }`.
// 3. We open the link in the external browser; user pays.
// 4. We surface a "I've finished paying" button so the user can trigger
//    server-side verification on return. (A proper deep-link handler can
//    call `confirmTopUp(txRef:)` automatically on app resume.)

Future<void> _showTopUpSheet(BuildContext context) async {
  final ctrl = context.read<WalletController>();
  final messenger = ScaffoldMessenger.of(context);

  final result = await showModalBottomSheet<({double amount, String currency})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _AmountInputSheet(
      title: 'Top Up Wallet',
      subtitle:
          'Enter the amount to add to your wallet. Payment is processed securely by Flutterwave.',
      submitLabel: 'Continue to Payment',
      currencyChoices: ['NGN', 'USD'],
    ),
  );

  if (result == null) return;

  await Future.delayed(Duration.zero);

  String? txRef;
  try {
    txRef = await ctrl.startTopUp(
      amount: result.amount,
      currency: result.currency,
    );
  } catch (e) {
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    messenger.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
    return;
  }

  if (txRef == null || txRef.isEmpty) return;
  if (!context.mounted) return;

  // Ask the user to confirm once they've returned from the Flutterwave page.
  await _showTopUpConfirmSheet(context, txRef: txRef);
}

Future<void> _showTopUpConfirmSheet(
  BuildContext context, {
  required String txRef,
}) async {
  await showModalBottomSheet<void>(
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
          final ctrl = sheetContext.read<WalletController>();
          final messenger = ScaffoldMessenger.of(sheetContext);

          Future<void> handleCheck() async {
            setSheetState(() => busy = true);
            try {
              await ctrl.confirmTopUp(txRef: txRef);
              if (!sheetContext.mounted) return;
              Navigator.of(sheetContext).pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Top-up confirmed — balance updated'),
                  backgroundColor: AppColors.primary,
                ),
              );
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
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Finish your top-up',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  "Once you've completed the payment in the browser, tap below so we can verify it with Flutterwave and credit your wallet.",
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
                    onPressed: busy ? null : handleCheck,
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
                            "I've completed the payment",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: busy ? null : () => Navigator.of(sheetContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Bottom sheet that collects a positive numeric amount plus an optional
/// currency selection.
class _AmountInputSheet extends StatefulWidget {
  const _AmountInputSheet({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    this.submitColor,
    this.currencyChoices = const ['NGN'],
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final Color? submitColor;
  final List<String> currencyChoices;

  @override
  State<_AmountInputSheet> createState() => _AmountInputSheetState();
}

class _AmountInputSheetState extends State<_AmountInputSheet> {
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _currency = widget.currencyChoices.first;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = _currency == 'USD' ? r'$' : '₦';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 18),
            if (widget.currencyChoices.length > 1) ...[
              Wrap(
                spacing: 8,
                children: widget.currencyChoices
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c),
                        selected: _currency == c,
                        onSelected: (_) => setState(() => _currency = c),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _amountCtrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currencySymbol ',
                border: const OutlineInputBorder(),
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
                  backgroundColor: widget.submitColor ?? AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(
                      (
                        amount: double.parse(_amountCtrl.text.trim()),
                        currency: _currency,
                      ),
                    );
                  }
                },
                child: Text(
                  widget.submitLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Withdraw flow ───────────────────────────────────────────────────────────
//
// Flow:
//   1. Refresh payout status from backend.
//   2. If no saved bank → present "Add bank account" sheet (select bank,
//      enter number, resolve, save).
//   3. Once saved → present withdraw-amount sheet, submit, refresh.

Future<void> _showWithdrawFlow(BuildContext context) async {
  final ctrl = context.read<WalletController>();
  final messenger = ScaffoldMessenger.of(context);

  Map<String, dynamic> status;
  try {
    status = await ctrl.refreshPayoutStatus();
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
    await _showAddBankSheet(context);
  } else {
    await _showWithdrawAmountSheet(context);
  }
}

Future<void> _showAddBankSheet(BuildContext context) async {
  final ctrl = context.read<WalletController>();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => _AddBankAccountSheet(controller: ctrl),
  );

  if (saved == true && context.mounted) {
    await _showWithdrawAmountSheet(context);
  }
}

Future<void> _showWithdrawAmountSheet(BuildContext context) async {
  final ctrl = context.read<WalletController>();
  final messenger = ScaffoldMessenger.of(context);

  final bank = ctrl.bankAccount;
  final bankSummary = bank == null
      ? 'your saved bank account'
      : '${bank['bankName'] ?? ''} • ${bank['number'] ?? ''}';

  final result = await showModalBottomSheet<({double amount, String currency})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AmountInputSheet(
      title: 'Withdraw to bank',
      subtitle:
          'Funds are sent via Flutterwave to $bankSummary. Settlement timing follows Flutterwave\'s payout schedule.',
      submitLabel: 'Withdraw',
      submitColor: AppColors.danger,
      currencyChoices: const ['NGN', 'USD'],
    ),
  );

  if (result == null) return;
  await Future.delayed(Duration.zero);

  try {
    await ctrl.withdraw(amount: result.amount, currency: result.currency);
    final symbol = result.currency == 'USD' ? r'$' : '₦';
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Withdrawal of $symbol${result.amount.toStringAsFixed(2)} sent',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  } catch (e) {
    final raw = e.toString();
    final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
    messenger.showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }
}

class _AddBankAccountSheet extends StatefulWidget {
  const _AddBankAccountSheet({required this.controller});

  final WalletController controller;

  @override
  State<_AddBankAccountSheet> createState() => _AddBankAccountSheetState();
}

class _AddBankAccountSheetState extends State<_AddBankAccountSheet> {
  final _accountCtrl = TextEditingController();
  Map<String, dynamic>? _selectedBank;
  List<Map<String, dynamic>>? _banks;
  String? _resolvedName;
  bool _loadingBanks = true;
  bool _resolving = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await widget.controller.fetchBanks();
      if (!mounted) return;
      setState(() {
        _banks = banks;
        _loadingBanks = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingBanks = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banks: $e')),
      );
    }
  }

  Future<void> _resolve() async {
    if (_selectedBank == null) return;
    if (_accountCtrl.text.trim().length < 10) return;

    setState(() {
      _resolving = true;
      _resolvedName = null;
    });
    try {
      final result = await widget.controller.resolveBankAccount(
        accountNumber: _accountCtrl.text.trim(),
        bankCode: _selectedBank!['code'].toString(),
      );
      if (!mounted) return;
      setState(() => _resolvedName = result['accountName']?.toString());
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _save() async {
    if (_selectedBank == null || _resolvedName == null) return;
    setState(() => _saving = true);
    try {
      await widget.controller.saveBankAccount(
        accountNumber: _accountCtrl.text.trim(),
        bankCode: _selectedBank!['code'].toString(),
        bankName: _selectedBank!['name']?.toString(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final msg = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add bank account',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Before you can withdraw, add the bank account funds should be paid into. Flutterwave will verify the account holder name.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.mutedText, height: 1.4),
          ),
          const SizedBox(height: 18),
          if (_loadingBanks)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            DropdownButtonFormField<Map<String, dynamic>>(
              initialValue: _selectedBank,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Bank',
                border: OutlineInputBorder(),
              ),
              items: (_banks ?? [])
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(
                        b['name']?.toString() ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (b) => setState(() {
                _selectedBank = b;
                _resolvedName = null;
              }),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _accountCtrl,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(
              labelText: 'Account number',
              counterText: '',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _resolvedName = null),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed:
                  _resolving || _selectedBank == null ? null : _resolve,
              child: _resolving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify account'),
            ),
          ),
          if (_resolvedName != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.subtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Account holder: $_resolvedName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed:
                  _saving || _resolvedName == null ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save bank account',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
