import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/member_shell.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class WalletRepository {
  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<WalletData> fetchWallet() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/payment/wallet');
    final data = res.data?['data'] as Map<String, dynamic>? ?? {};
    return WalletData.fromJson(data);
  }

  Future<List<WalletTransaction>> fetchTransactions() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/payment/transactions');
    final raw = res.data?['data'] as List<dynamic>? ?? [];
    return raw.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class WalletData {
  const WalletData({required this.balance, required this.transactions});

  final double balance;
  final List<WalletTransaction> transactions;

  factory WalletData.fromJson(Map<String, dynamic> json) {
    final txRaw = json['transactions'] as List<dynamic>? ?? [];
    return WalletData(
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: txRaw.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String type;
  final double amount;
  final String status;
  final DateTime createdAt;

  bool get isTopUp =>
      type.toLowerCase().contains('top') || type.toLowerCase().contains('deposit');

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? 'payment').toString(),
      amount: (json['price'] ?? json['amount'] ?? 0).toDouble(),
      status: (json['paymentStatus'] ?? 'pending').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository repository}) : _repo = repository;

  final WalletRepository _repo;

  WalletData? wallet;
  List<WalletTransaction> transactions = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      wallet = await _repo.fetchWallet();
      transactions = wallet?.transactions ?? [];
    } catch (e) {
      errorMessage = e.toString();
      transactions = _mockTransactions();
      wallet = WalletData(balance: 34671.80, transactions: transactions);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<WalletTransaction> _mockTransactions() {
    final now = DateTime.now();
    return [
      WalletTransaction(id: '1', type: 'topup', amount: 2000, status: 'complete', createdAt: now),
      WalletTransaction(id: '2', type: 'topup', amount: 2000, status: 'complete', createdAt: now.subtract(const Duration(days: 1))),
      WalletTransaction(id: '3', type: 'withdraw', amount: 80, status: 'complete', createdAt: now.subtract(const Duration(days: 2))),
      WalletTransaction(id: '4', type: 'withdraw', amount: 20, status: 'complete', createdAt: now.subtract(const Duration(days: 3))),
      WalletTransaction(id: '5', type: 'topup', amount: 2000, status: 'complete', createdAt: now.subtract(const Duration(days: 4))),
      WalletTransaction(id: '6', type: 'withdraw', amount: 80, status: 'complete', createdAt: now.subtract(const Duration(days: 5))),
    ];
  }
}

// ─── Wallet Screen ────────────────────────────────────────────────────────────

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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
    final naira = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return MemberShell(
      currentIndex: 2,
      title: 'Wallet',
      child: RefreshIndicator(
        onRefresh: ctrl.load,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Balance Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ctrl.wallet != null ? naira.format(ctrl.wallet!.balance) : '₦0.00',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick Actions ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Action',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.arrow_upward_rounded,
                          label: 'Tap Up',
                          color: AppColors.primary,
                          bgColor: AppColors.subtle,
                          onTap: () => _showTopUpSheet(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.arrow_downward_rounded,
                          label: 'Withdraw',
                          color: AppColors.danger,
                          bgColor: AppColors.dangerLight,
                          onTap: () => _showWithdrawSheet(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Transactions ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (ctrl.isLoading && ctrl.transactions.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ))
            else
              ...ctrl.transactions.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TransactionRow(transaction: t, formatter: naira),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context) {
    final amtCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Up Wallet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₦ ',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm Top Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final amtCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Withdraw Funds',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₦ ',
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: () => Navigator.pop(context),
                child: const Text('Withdraw'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction, required this.formatter});

  final WalletTransaction transaction;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final isTopUp = transaction.isTopUp;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isTopUp ? AppColors.subtle : AppColors.dangerLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isTopUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isTopUp ? AppColors.primary : AppColors.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTopUp ? 'Tap Up' : 'Withdraw',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  DateFormat('MMM d').format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
          Text(
            formatter.format(transaction.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isTopUp ? AppColors.primary : AppColors.danger,
                ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, size: 18, color: AppColors.mutedText),
        ],
      ),
    );
  }
}
