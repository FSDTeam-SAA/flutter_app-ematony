import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/member_shell.dart';
import '../auth/auth_controller.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class HomeRepository {
  HomeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<HomeDashboard> fetchDashboard() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/dashboard/home');
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    return HomeDashboard.fromJson(data);
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class HomeDashboard {
  const HomeDashboard({
    required this.balance,
    required this.upcomingPaymentName,
    required this.upcomingPaymentAmount,
    required this.activeGroups,
    required this.pendingRequests,
    required this.recentTransactions,
    required this.recentNotifications,
  });

  final double balance;
  final String upcomingPaymentName;
  final double upcomingPaymentAmount;
  final int activeGroups;
  final int pendingRequests;
  final List<ActivityTransaction> recentTransactions;
  final List<ActivityNotification> recentNotifications;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    final wallet = json['walletSummary'] as Map<String, dynamic>? ?? {};
    final upcoming = json['upcomingPayment'] as Map<String, dynamic>? ?? {};
    return HomeDashboard(
      balance: (wallet['balance'] ?? wallet['totalCompleted'] ?? 0).toDouble(),
      upcomingPaymentName: (upcoming['groupName'] ?? '').toString(),
      upcomingPaymentAmount: (upcoming['amount'] ?? 0).toDouble(),
      activeGroups: (json['activeGroups'] ?? 0) as int,
      pendingRequests: (json['pendingRequests'] ?? 0) as int,
      recentTransactions: ((json['recentTransactions'] as List<dynamic>?) ?? [])
          .map((e) => ActivityTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentNotifications: ((json['recentNotifications'] as List<dynamic>?) ?? [])
          .map((e) => ActivityNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivityTransaction {
  const ActivityTransaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String status;
  final String type;
  final DateTime createdAt;

  bool get isTopUp => type.toLowerCase().contains('top') || type.toLowerCase().contains('deposit');

  factory ActivityTransaction.fromJson(Map<String, dynamic> json) {
    return ActivityTransaction(
      id: (json['_id'] ?? '').toString(),
      amount: (json['price'] ?? json['amount'] ?? 0).toDouble(),
      status: (json['paymentStatus'] ?? 'pending').toString(),
      type: (json['type'] ?? 'payment').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

class ActivityNotification {
  const ActivityNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.isTopUp,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String content;
  final bool isTopUp;
  final DateTime createdAt;

  factory ActivityNotification.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? 'Notification').toString();
    return ActivityNotification(
      id: (json['_id'] ?? '').toString(),
      title: title,
      content: (json['content'] ?? '').toString(),
      isTopUp: title.toLowerCase().contains('top') || title.toLowerCase().contains('add'),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class HomeController extends ChangeNotifier {
  HomeController({required HomeRepository repository}) : _repo = repository;

  final HomeRepository _repo;

  HomeDashboard? dashboard;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      dashboard = await _repo.fetchDashboard();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// ─── Home Screen ──────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HomeController>();
    final user = context.watch<AuthController>().currentUser;
    final naira = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

    return MemberShell(
      currentIndex: 0,
      title: '',
      child: RefreshIndicator(
        onRefresh: ctrl.load,
        color: AppColors.primary,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.subtle,
                    backgroundImage: null,
                    child: Text(
                      (user?.name.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transactions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                        Text(
                          user?.name ?? 'Ematony',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/notifications'),
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 26),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Balance Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                      'Your Balance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ctrl.dashboard != null
                          ? naira.format(ctrl.dashboard!.balance)
                          : '₦0.00',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (ctrl.dashboard?.upcomingPaymentName.isNotEmpty == true) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upcoming Payment',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.mutedText,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ctrl.dashboard!.upcomingPaymentName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    naira.format(ctrl.dashboard!.upcomingPaymentAmount),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _AutoPayToggle(),
                                const SizedBox(width: 12),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                  onPressed: () {},
                                  child: const Text('Pay Now'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Active Groups ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Active Groups',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/groups'),
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            if (ctrl.isLoading && ctrl.dashboard == null)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ctrl.dashboard != null && ctrl.dashboard!.recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _EmptyCard(message: 'No active groups yet. Create or join one!'),
              )
            else
              SizedBox(
                height: 130,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: ctrl.dashboard?.activeGroups ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _GroupCard(
                    name: 'Group ${i + 1}',
                    progress: (i + 1) / 3,
                    rotation: '${i + 1} of 3',
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // ── Quick Actions ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Quick Action',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _QuickActionBtn(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Tap Up',
                    onTap: () => context.push('/wallet'),
                    tint: AppColors.subtle,
                    iconColor: AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  _QuickActionBtn(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Withdraw',
                    onTap: () => context.push('/wallet'),
                    tint: AppColors.dangerLight,
                    iconColor: AppColors.danger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Recent Transactions ──
            if (ctrl.dashboard != null &&
                ctrl.dashboard!.recentTransactions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/wallet'),
                      child: const Text('View Balance'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...ctrl.dashboard!.recentTransactions.take(5).map(
                    (t) => _TransactionItem(transaction: t, formatter: naira),
                  ),
              const SizedBox(height: 8),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-Widgets ──────────────────────────────────────────────────────────────

class _AutoPayToggle extends StatefulWidget {
  @override
  State<_AutoPayToggle> createState() => _AutoPayToggleState();
}

class _AutoPayToggleState extends State<_AutoPayToggle> {
  bool _enabled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Auto\nPayment',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.mutedText,
                height: 1.3,
              ),
          textAlign: TextAlign.center,
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.subtle,
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.name,
    required this.progress,
    required this.rotation,
  });

  final String name;
  final double progress;
  final String rotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Rotation - $rotation',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedText,
                ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}% Completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tint,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color tint;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.transaction, required this.formatter});

  final ActivityTransaction transaction;
  final NumberFormat formatter;

  @override
  Widget build(BuildContext context) {
    final isTopUp = transaction.isTopUp;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    DateFormat('dd MMM yyyy').format(transaction.createdAt),
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
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        textAlign: TextAlign.center,
      ),
    );
  }
}
