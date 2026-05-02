import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/mock/app_mock_data.dart';
import '../../core/models/payment_model.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class WalletRepository {
  WalletRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<PaymentModel>> fetchMyPayments({int limit = 50}) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        '/payment/me',
        queryParameters: {'limit': limit},
      );
      final raw = response.data?['data'];
      if (raw is List) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(PaymentModel.fromJson)
            .toList();
      }
      return [];
    } catch (_) {
      return AppMockData.transactions()
          .map(PaymentModel.fromJson)
          .toList();
    }
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class WalletController extends ChangeNotifier {
  WalletController({required WalletRepository repository})
      : _repository = repository;

  final WalletRepository _repository;

  bool isLoading = false;
  List<PaymentModel> transactions = [];
  String? error;

  double get balance {
    double b = 0;
    for (final t in transactions) {
      if (t.isTopUp) {
        b += t.price;
      } else if (t.isWithdraw) {
        b -= t.price;
      }
    }
    return b < 0 ? 0 : b;
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      transactions = await _repository.fetchMyPayments();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// ─── WalletScreen ─────────────────────────────────────────────────────────────

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
        ? '₦${ctrl.balance.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
        : '₦••••••';

    return AjoScaffold(
      currentIndex: 2,
      body: SafeArea(
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
                  height: 188,
                  bottomRadius: 28,
                  child: Column(
                    children: [
                      const SizedBox(height: 36),
                      Text(
                        'Your Balance',
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
                        onPressed: () =>
                            setState(() => _balanceVisible = !_balanceVisible),
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
                          _ActionSquare(
                            icon: Icons.north_east_rounded,
                            iconBg: AppColors.subtle,
                            iconColor: AppColors.primary,
                            label: 'Top Up',
                            onTap: () => _showSnackBar(
                                context, 'Top up flow coming soon.'),
                          ),
                          const SizedBox(width: 18),
                          _ActionSquare(
                            icon: Icons.north_rounded,
                            quarterTurns: 2,
                            iconBg: AppColors.dangerLight,
                            iconColor: AppColors.danger,
                            label: 'Withdraw',
                            onTap: () => _showSnackBar(
                                context, 'Withdraw flow coming soon.'),
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
                        AjoCard(
                          radius: 22,
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No transactions yet.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: AppColors.mutedText),
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
      ),
    );
  }
}

// ─── TransactionHistoryScreen ─────────────────────────────────────────────────

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

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _ActionSquare extends StatelessWidget {
  const _ActionSquare({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.quarterTurns = 0,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: RotatedBox(
              quarterTurns: quarterTurns,
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
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
            child: RotatedBox(
              quarterTurns: tx.isTopUp ? 0 : 2,
              child: Icon(
                Icons.north_east_rounded,
                color: tx.isTopUp ? AppColors.primary : AppColors.danger,
                size: 24,
              ),
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(message), backgroundColor: AppColors.primary),
  );
}
