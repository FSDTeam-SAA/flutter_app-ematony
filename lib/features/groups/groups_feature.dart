import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/member_shell.dart';

// ─── Repository ───────────────────────────────────────────────────────────────

class GroupsRepository {
  GroupsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<GroupSummary>> fetchGroups() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/groups');
    final raw = res.data?['data'] as List<dynamic>? ?? [];
    return raw.map((e) => GroupSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<GroupSummary>> fetchRequests() async {
    final res = await _apiClient.dio.get<Map<String, dynamic>>('/groups/requests');
    final raw = res.data?['data'] as List<dynamic>? ?? [];
    return raw.map((e) => GroupSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<GroupDetail> fetchGroupDetail(String id) async {
    final detail = await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id');
    final members = await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id/members');
    final wheel = await _apiClient.dio.get<Map<String, dynamic>>('/groups/$id/wheel');
    return GroupDetail.fromPayload(
      detail.data?['data'] as Map<String, dynamic>? ?? {},
      members.data?['data'] as List<dynamic>? ?? [],
      wheel.data?['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<String> joinByCode(String inviteCode) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/groups/join-by-code',
      data: {'inviteCode': inviteCode},
    );
    return (res.data?['data']?['_id'] ?? '').toString();
  }

  Future<GroupSummary> createGroup({
    required String name,
    required String amount,
    required String frequency,
    required String maxMembers,
    required String cycleDuration,
    required bool autoPayments,
  }) async {
    final res = await _apiClient.dio.post<Map<String, dynamic>>(
      '/groups',
      data: {
        'name': name,
        'contributionAmount': double.tryParse(amount) ?? 0,
        'contributionFrequency': frequency,
        'maxMembers': int.tryParse(maxMembers) ?? 5,
        'cycleDuration': int.tryParse(cycleDuration) ?? 12,
        'autoPayments': autoPayments,
      },
    );
    return GroupSummary.fromJson(
        res.data?['data'] as Map<String, dynamic>? ?? {});
  }

  Future<void> joinGroup(String groupId) async {
    await _apiClient.dio.post('/groups/$groupId/join');
  }
}

// ─── Models ───────────────────────────────────────────────────────────────────

class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.name,
    required this.description,
    required this.inviteCode,
    required this.status,
    required this.contributionAmount,
    required this.frequency,
    required this.maxMembers,
    required this.memberCount,
    required this.progress,
  });

  final String id;
  final String name;
  final String description;
  final String inviteCode;
  final String status;
  final double contributionAmount;
  final String frequency;
  final int maxMembers;
  final int memberCount;
  final double progress;

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    final max = (json['maxMembers'] ?? 1) as int;
    final count = (json['memberCount'] ?? json['members']?.length ?? 0) as int;
    return GroupSummary(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      inviteCode: (json['inviteCode'] ?? '').toString(),
      status: (json['status'] ?? 'active').toString(),
      contributionAmount: (json['contributionAmount'] ?? 0).toDouble(),
      frequency: (json['contributionFrequency'] ?? 'Monthly').toString(),
      maxMembers: max,
      memberCount: count,
      progress: max > 0 ? count / max : 0,
    );
  }
}

class GroupMember {
  const GroupMember({
    required this.name,
    required this.role,
    required this.position,
    required this.paymentStatus,
  });

  final String name;
  final String role;
  final int position;
  final String paymentStatus;

  bool get isPaid => paymentStatus.toLowerCase() == 'paid' || paymentStatus.toLowerCase() == 'complete';
  bool get isPending => paymentStatus.toLowerCase() == 'pending';

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map<String, dynamic>? ?? {};
    return GroupMember(
      name: (user['name'] ?? user['email'] ?? 'Member').toString(),
      role: (json['membershipRole'] ?? 'member').toString(),
      position: (json['payoutPosition'] ?? 0) as int,
      paymentStatus: (json['paymentStatus'] ?? 'pending').toString(),
    );
  }
}

class GroupRotation {
  const GroupRotation({required this.name, required this.position});

  final String name;
  final int position;

  factory GroupRotation.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return GroupRotation(
      name: (user['name'] ?? user['email'] ?? 'Member').toString(),
      position: (json['positionNumber'] ?? 0) as int,
    );
  }
}

class GroupDetail {
  const GroupDetail({
    required this.group,
    required this.members,
    required this.rotations,
    required this.inviteCode,
    required this.nextWheelDate,
    required this.contributionAmount,
  });

  final GroupSummary group;
  final List<GroupMember> members;
  final List<GroupRotation> rotations;
  final String inviteCode;
  final String nextWheelDate;
  final double contributionAmount;

  factory GroupDetail.fromPayload(
    Map<String, dynamic> detail,
    List<dynamic> membersPayload,
    Map<String, dynamic> wheelPayload,
  ) {
    final groupJson = detail['group'] as Map<String, dynamic>? ?? detail;
    final rotationPayload = wheelPayload['rotations'] as List<dynamic>? ?? [];
    final group = GroupSummary.fromJson(groupJson);
    return GroupDetail(
      group: group,
      members: membersPayload
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      rotations: rotationPayload
          .map((e) => GroupRotation.fromJson(e as Map<String, dynamic>))
          .toList(),
      inviteCode: group.inviteCode,
      nextWheelDate: (wheelPayload['nextWheelDate'] ?? '').toString(),
      contributionAmount: group.contributionAmount,
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class GroupsController extends ChangeNotifier {
  GroupsController({required GroupsRepository repository}) : _repo = repository;

  final GroupsRepository _repo;

  List<GroupSummary> groups = [];
  List<GroupSummary> requests = [];
  GroupDetail? detail;
  GroupSummary? createdGroup;
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      groups = await _repo.fetchGroups();
      requests = await _repo.fetchRequests();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetail(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      detail = await _repo.fetchGroupDetail(id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinByCode(String code) async {
    try {
      await _repo.joinByCode(code);
      await load();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinGroup(String groupId) async {
    try {
      await _repo.joinGroup(groupId);
      await load();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> createGroup({
    required String name,
    required String amount,
    required String frequency,
    required String maxMembers,
    required String cycleDuration,
    required bool autoPayments,
  }) async {
    try {
      createdGroup = await _repo.createGroup(
        name: name,
        amount: amount,
        frequency: frequency,
        maxMembers: maxMembers,
        cycleDuration: cycleDuration,
        autoPayments: autoPayments,
      );
      await load();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

// ─── Groups Screen ────────────────────────────────────────────────────────────

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsController>().load();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return MemberShell(
      currentIndex: 1,
      title: 'Groups',
      child: Column(
        children: [
          // ── Create Group Banner ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: GestureDetector(
              onTap: () => context.push('/groups/create'),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a New Savings Group',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Start a group and save together',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
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

          const SizedBox(height: 16),

          // ── Tabs ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.mutedText,
                labelStyle: Theme.of(context).textTheme.labelLarge,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Active Groups'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab Content ──
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _ActiveGroupsTab(ctrl: ctrl),
                _RequestsTab(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveGroupsTab extends StatelessWidget {
  const _ActiveGroupsTab({required this.ctrl});
  final GroupsController ctrl;

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading && ctrl.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No active groups yet.\nCreate one or join with a code!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedText,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ctrl.groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final g = ctrl.groups[i];
        return _GroupCard(
          group: g,
          onTap: () => context.push('/groups/${g.id}'),
          trailing: null,
        );
      },
    );
  }
}

class _RequestsTab extends StatelessWidget {
  const _RequestsTab({required this.ctrl});
  final GroupsController ctrl;

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading && ctrl.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'No open groups to join right now.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.push('/groups/enter-code'),
                icon: const Icon(Icons.vpn_key_outlined),
                label: const Text('Enter Invite Code'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: ctrl.requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final g = ctrl.requests[i];
        return _GroupCard(
          group: g,
          trailing: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              final ok = await context.read<GroupsController>().joinGroup(g.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Join request sent!' : ctrl.errorMessage ?? 'Failed'),
                  backgroundColor: ok ? AppColors.primary : AppColors.danger,
                ),
              );
            },
            child: const Text('Join Group'),
          ),
          badge: 'Open',
        );
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    this.onTap,
    this.trailing,
    this.badge,
  });

  final GroupSummary group;
  final VoidCallback? onTap;
  final Widget? trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.subtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Rotation - ${group.memberCount} of ${group.maxMembers}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 24,
                  child: Stack(
                    children: List.generate(
                      group.memberCount.clamp(0, 4),
                      (i) => Positioned(
                        left: i * 14.0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: [
                            AppColors.primary,
                            AppColors.success,
                            AppColors.warning,
                            AppColors.danger,
                          ][i % 4],
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: group.progress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(group.progress * 100).toInt()}% Completed',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedText,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Enter Code Screen ────────────────────────────────────────────────────────

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  title: const Text(
                    'Enter Code',
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.subtle,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.widgets_outlined, color: AppColors.primary, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create a New Savings Group',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter a group code below to join',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _codeCtrl,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                          decoration: const InputDecoration(
                            hintText: 'Type your code...',
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: ctrl.isLoading
                                ? null
                                : () async {
                                    final ok = await ctrl.joinByCode(_codeCtrl.text.trim());
                                    if (!context.mounted) return;
                                    if (ok) {
                                      context.go('/groups');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(ctrl.errorMessage ?? 'Invalid code'),
                                          backgroundColor: AppColors.danger,
                                        ),
                                      );
                                    }
                                  },
                            child: ctrl.isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Join Group'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Create Group Screen ──────────────────────────────────────────────────────

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _membersCtrl = TextEditingController(text: '12');
  final _cycleCtrl = TextEditingController(text: '12');
  String _frequency = 'Monthly';
  bool _autoPayments = true;

  static const _frequencies = ['Daily', 'Weekly', 'Monthly', 'Quarterly'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _membersCtrl.dispose();
    _cycleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create a New Savings Group'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupField(label: 'Group Name', controller: _nameCtrl, hint: 'Family Savings 2026'),
              const SizedBox(height: 16),
              _GroupFieldLabel(label: 'Frequency'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _frequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v ?? 'Monthly'),
              ),
              const SizedBox(height: 16),
              _GroupField(
                label: 'Amount',
                controller: _amountCtrl,
                hint: '₦1000.00',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _GroupField(
                label: 'Number of Members',
                controller: _membersCtrl,
                hint: '12',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _GroupField(
                label: 'Cycle Duration',
                controller: _cycleCtrl,
                hint: 'Auto-calculated based on members',
                readOnly: true,
              ),
              const SizedBox(height: 16),
              _GroupFieldLabel(label: 'Group Code'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.copy_outlined, size: 18, color: AppColors.mutedText),
                    const SizedBox(width: 8),
                    Text(
                      '#123456',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mutedText,
                            letterSpacing: 2,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'Auto-generated',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automatic Payments',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Text(
                          'You need to enable automatic payments for this group.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedText,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _autoPayments,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _autoPayments = v),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: ctrl.isLoading
                      ? null
                      : () async {
                          final ok = await ctrl.createGroup(
                            name: _nameCtrl.text.trim(),
                            amount: _amountCtrl.text.trim(),
                            frequency: _frequency,
                            maxMembers: _membersCtrl.text.trim(),
                            cycleDuration: _cycleCtrl.text.trim(),
                            autoPayments: _autoPayments,
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            context.pushReplacement('/groups/created');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ctrl.errorMessage ?? 'Failed to create group'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          }
                        },
                  child: ctrl.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupFieldLabel extends StatelessWidget {
  const _GroupFieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}

class _GroupField extends StatelessWidget {
  const _GroupField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupFieldLabel(label: label),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ─── Group Created Successfully ───────────────────────────────────────────────

class GroupCreatedScreen extends StatelessWidget {
  const GroupCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();
    final code = ctrl.createdGroup?.inviteCode ?? '------';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Group Created\nSuccessfully!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.subtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '#$code',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 4,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share this code with\nyour friends',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => context.go('/groups'),
                  child: const Text('View Groups'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Group Detail Screen ──────────────────────────────────────────────────────

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsController>().loadDetail(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();
    final detail = ctrl.detail;

    if (ctrl.isLoading && detail == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (detail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Details')),
        body: Center(child: Text(ctrl.errorMessage ?? 'Group not found')),
      );
    }

    final naira = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(detail.group.name),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Edit')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Summary ──
          Container(
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
                  'Group Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.savings_outlined,
                      label: 'Contribution',
                      value: naira.format(detail.contributionAmount),
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.people_outline,
                      label: 'Member',
                      value: detail.members.length.toString(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Upcoming Payment ──
          Container(
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
                  'Upcoming Payment',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                ),
                Text(
                  detail.group.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      naira.format(detail.contributionAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Text('Auto Payment'),
                        Switch(
                          value: true,
                          activeTrackColor: AppColors.primary,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

          const SizedBox(height: 16),

          // ── Members ──
          Container(
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
                  'Group Members',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...detail.members.map(
                  (member) => _MemberTile(member: member),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Actions ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  label: const Text('Invite Member'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => context.push('/support/new'),
                  icon: const Icon(Icons.headset_mic_outlined, size: 18),
                  label: const Text('Contact Admin'),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.dangerLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _confirmLeave(context),
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _confirmLeave(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Group?'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final GroupMember member;

  @override
  Widget build(BuildContext context) {
    final isCreator = member.role.toLowerCase() == 'admin' ||
        member.role.toLowerCase() == 'creator';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.subtle,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.subtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Group Creator',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: member.isPaid ? AppColors.subtle : AppColors.warningLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              member.isPaid ? 'Paid' : 'Pending',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: member.isPaid ? AppColors.primary : AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Admin Screen ─────────────────────────────────────────────────────

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({super.key});

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final _nameCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = 'Payment Issue';

  static const _categories = [
    'Payment Issue',
    'Group Problem',
    'Account Issue',
    'Technical Issue',
    'Other',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Contact Admin'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GroupField(label: 'Full Name', controller: _nameCtrl, hint: 'Enter Your Name'),
              const SizedBox(height: 16),
              _GroupField(label: 'Group Name', controller: _groupCtrl, hint: 'Select group name'),
              const SizedBox(height: 16),
              const _GroupFieldLabel(label: 'Issue Category'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),
              _GroupField(
                label: 'Message',
                controller: _messageCtrl,
                hint: 'Write your message here',
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => context.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Message sent to admin'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        context.pop();
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
