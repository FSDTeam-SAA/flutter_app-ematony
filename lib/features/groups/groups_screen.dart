import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/models/group_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/ajo_chrome.dart';
import '../../core/widgets/labeled_text_field.dart';
import '../../core/widgets/primary_button.dart';
import 'groups_controller.dart';
import 'groups_repository.dart';

// ─── GroupsScreen ─────────────────────────────────────────────────────────────

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  bool _showRequests = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupsController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<GroupsController>().load(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 110),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => context.push('/groups/create'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(18),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withAlpha(170)),
                          ),
                          child:
                              const Icon(Icons.add, color: Colors.white),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Create a New Savings Group',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start a group and savings together',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: const Color(0xFF00B384)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _GroupsTabHeader(
                  showRequests: _showRequests,
                  onToggle: (val) => setState(() => _showRequests = val),
                  requestCount: ctrl.requestGroups.length,
                ),
                const SizedBox(height: 20),
                if (ctrl.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  if (_showRequests) ...[
                    if (ctrl.requestGroups.isEmpty)
                      _EmptyState(
                          message: 'No pending group requests.',
                          onJoin: () =>
                              context.push('/groups/enter-code'))
                    else
                      for (final group in ctrl.requestGroups) ...[
                        _RequestCard(
                          title: group.name,
                          memberCount: group.membersCount,
                          onOpen: () =>
                              context.push('/groups/${group.id}'),
                          onJoin: () =>
                              context.push('/groups/enter-code'),
                        ),
                        const SizedBox(height: 16),
                      ],
                  ] else ...[
                    if (ctrl.activeGroups.isEmpty)
                      _EmptyState(
                          message: 'No active groups yet.',
                          onJoin: () =>
                              context.push('/groups/enter-code'))
                    else
                      for (final group in ctrl.activeGroups) ...[
                        _ActiveGroupCard(
                          group: group,
                          onTap: () =>
                              context.push('/groups/${group.id}'),
                        ),
                        const SizedBox(height: 16),
                      ],
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── EnterCodeScreen ──────────────────────────────────────────────────────────

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(110),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined,
                    color: Colors.white, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Enter Code for joining this group',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Type your code..',
                  ),
                ),
                if (ctrl.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ctrl.error!,
                      style: const TextStyle(
                          color: Color(0xFFFF6B6B), fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withAlpha(80)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: ctrl.isJoining
                            ? null
                            : () async {
                                final code = _codeController.text.trim();
                                if (code.isEmpty) return;
                                final ctrl = context.read<GroupsController>();
                                final groupId = await ctrl.joinByCode(code);
                                if (!mounted) return;
                                if (groupId != null) {
                                  context.go('/groups/$groupId');
                                }
                              },
                        child: ctrl.isJoining
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white),
                              )
                            : const Text('Join'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── CreateGroupScreen ────────────────────────────────────────────────────────

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

// frequency label → backend enum value
const _freqLabels = ['Weekly', 'Bi-Weekly', 'Monthly'];
const _freqValues = ['weekly', 'biweekly', 'monthly'];
// member display options (matching design: 3 min → 36 max)
const _memberOptions = ['3', '6', '12', '24', '36'];

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController(text: 'Family Savings 2026');
  String _frequencyLabel = 'Monthly';      // shown in dropdown
  final _amountController = TextEditingController(text: '1000.00');
  String _members = '12';
  bool _autoPay = true;

  String get _frequencyValue =>
      _freqValues[_freqLabels.indexOf(_frequencyLabel)];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<GroupsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AjoBackHeader(title: 'Create a New Savings Group'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                children: [
                  LabeledTextField(
                      label: 'Group Name', controller: _nameController),
                  const SizedBox(height: 14),
                  _LabeledDropdown(
                    label: 'Frequency',
                    value: _frequencyLabel,
                    items: _freqLabels,
                    onChanged: (v) =>
                        setState(() => _frequencyLabel = v!),
                  ),
                  const SizedBox(height: 14),
                  LabeledTextField(
                    label: 'Amount',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _LabeledDropdown(
                    label: 'Number of Members',
                    value: _members,
                    items: _memberOptions,
                    itemLabelBuilder: (v) => v == _memberOptions.first
                        ? '$v Minimum'
                        : v == _memberOptions.last
                            ? '$v Maximum'
                            : v,
                    onChanged: (v) => setState(() => _members = v!),
                  ),
                  const SizedBox(height: 14),
                  _ReadOnlyField(
                    label: 'Cycle Duration',
                    value: 'auto-calculated based on members',
                  ),
                  const SizedBox(height: 14),
                  _ReadOnlyField(
                    label: 'Group Code',
                    value: '#auto-generated',
                    trailing: const Icon(Icons.copy_outlined,
                        size: 18, color: AppColors.primary),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4, top: 6),
                      child: Text(
                        'Automatically generated by the system.',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AjoCard(
                    radius: 18,
                    borderColor: const Color(0xFFF0E2C9),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Automatic Payments',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            _SwitchPill(
                              value: _autoPay,
                              onChanged: (v) =>
                                  setState(() => _autoPay = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You must enable automatic payments to create this group.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.text),
                        ),
                      ],
                    ),
                  ),
                  if (ctrl.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(ctrl.error!,
                          style:
                              const TextStyle(color: AppColors.danger)),
                    ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Create Group',
                    loading: ctrl.isCreating,
                    onPressed: () async {
                      if (_nameController.text.trim().isEmpty) return;
                      final groupsCtrl = context.read<GroupsController>();
                      final ok = await groupsCtrl.createGroup(
                        name: _nameController.text.trim(),
                        amount: _amountController.text.trim(),
                        frequency: _frequencyValue,
                        maxMembers: _members,
                        cycleDuration: _members,
                        autoPayments: _autoPay,
                      );
                      if (!mounted) return;
                      if (ok) context.go('/groups/created');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── GroupCreatedScreen ───────────────────────────────────────────────────────

class GroupCreatedScreen extends StatelessWidget {
  const GroupCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inviteCode =
        context.read<GroupsController>().createdInviteCode ?? '#123456';

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9FBF3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 42),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Group Created\nSuccessfully!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          color: const Color(0xFFFF7A1A),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 26),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      inviteCode,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Share this code with\nyour friends.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
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

// ─── GroupDetailScreen ────────────────────────────────────────────────────────

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Map<String, dynamic> _detail = {};
  List<GroupMemberModel> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final repo = context.read<GroupsRepository>();
    final results = await Future.wait([
      repo.getGroupDetails(widget.groupId),
      repo.getGroupMembers(widget.groupId),
    ]);
    if (!mounted) return;
    setState(() {
      _detail = results[0] as Map<String, dynamic>;
      _members = results[1] as List<GroupMemberModel>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = _detail['group'] as Map<String, dynamic>?;
    final summary = _detail['summary'] as Map<String, dynamic>?;
    final groupName = group?['name']?.toString() ?? 'Group Details';
    final amount = (group?['contributionAmount'] as num?)?.toDouble() ?? 0;
    final totalPool = amount * (_members.isNotEmpty ? _members.length : 1);
    final membersCount = (summary?['membersCount'] as num?)?.toInt() ??
        _members.length;
    final status = (group?['status'] ?? 'active').toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AjoBackHeader(title: groupName),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _InfoCard(
                          title: 'Group Summary',
                          child: Column(
                            children: [
                              _SummaryRow(label: 'Status', value: status.toUpperCase()),
                              _SummaryRow(
                                label: 'Contribution Amount',
                                value: '₦${amount.toStringAsFixed(2)}',
                              ),
                              _SummaryRow(
                                label: 'Number of Members',
                                value: membersCount.toString(),
                              ),
                              _SummaryRow(
                                label: 'Total Pool',
                                value: '₦${totalPool.toStringAsFixed(2)}',
                              ),
                              _SummaryRow(
                                label: 'Frequency',
                                value:
                                    group?['contributionFrequency']?.toString() ??
                                        'Monthly',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          title: 'Upcoming Payment',
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '₦${amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              FilledButton(
                                onPressed: () => _showSnackBar(
                                    context, 'Payment initiated.'),
                                child: const Text('Pay Now'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _InfoCard(
                          title: 'Group Members',
                          child: Column(
                            children: _members
                                .map(
                                  (m) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        AjoAvatar(
                                            name: m.name, radius: 18),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            m.name,
                                            style: const TextStyle(
                                              color: AppColors.text,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: m.isLastWinner
                                                ? AppColors.warningLight
                                                : AppColors.subtle,
                                            borderRadius:
                                                BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            m.isLastWinner
                                                ? 'Last Winner'
                                                : 'Pending',
                                            style: TextStyle(
                                              color: m.isLastWinner
                                                  ? AppColors.warning
                                                  : AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showSnackBar(
                                  context,
                                  'Share invite code with friends!',
                                ),
                                child: const Text('Invite Member'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    context.push('/support/new'),
                                child: const Text('Contact Admin'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => context.push('/wheel'),
                          child: const Text('Open Wheel'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: const Text(
                            'Leave Group',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ContactAdminScreen extends StatefulWidget {
  const ContactAdminScreen({super.key});

  @override
  State<ContactAdminScreen> createState() => _ContactAdminScreenState();
}

class _ContactAdminScreenState extends State<ContactAdminScreen> {
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  final _categoryController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _categoryController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AjoBackHeader(title: 'Contact Admin'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                LabeledTextField(
                    label: 'Full Name', controller: _nameController),
                const SizedBox(height: 14),
                LabeledTextField(
                    label: 'Group Name', controller: _groupController),
                const SizedBox(height: 14),
                LabeledTextField(
                    label: 'Issue Category',
                    controller: _categoryController),
                const SizedBox(height: 14),
                LabeledTextField(
                  label: 'Message',
                  controller: _messageController,
                  maxLines: 5,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          _showSnackBar(
                              context, 'Message sent to the admin.');
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
        ],
      ),
    );
  }
}

// ─── Private Widgets ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, required this.onJoin});

  final String message;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AjoCard(
      radius: 20,
      child: Column(
        children: [
          Text(message,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.mutedText)),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: onJoin, child: const Text('Join with Code')),
        ],
      ),
    );
  }
}

class _GroupsTabHeader extends StatelessWidget {
  const _GroupsTabHeader({
    required this.showRequests,
    required this.onToggle,
    required this.requestCount,
  });

  final bool showRequests;
  final ValueChanged<bool> onToggle;
  final int requestCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTab(
              label: 'Active Groups',
              icon: Icons.blur_circular_outlined,
              active: !showRequests,
              onTap: () => onToggle(false),
            ),
          ),
          Expanded(
            child: _SegmentTab(
              label: 'Requests${requestCount > 0 ? ' ($requestCount)' : ''}',
              icon: Icons.check_circle_outline_rounded,
              active: showRequests,
              onTap: () => onToggle(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: active ? Colors.white : AppColors.text),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: active ? Colors.white : AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveGroupCard extends StatelessWidget {
  const _ActiveGroupCard({required this.group, required this.onTap});

  final GroupModel group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pct = (group.completionPercent * 100).toInt();
    return GestureDetector(
      onTap: onTap,
      child: AjoCard(
        radius: 20,
        borderColor: const Color(0xFFF0E2C9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$pct%',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text('Completed',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Rotation : ${group.membersCount} of ${group.maxMembers}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: group.completionPercent,
                minHeight: 7,
                backgroundColor: const Color(0xFFF5EBD7),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const _SmallMemberCluster(),
                const Spacer(),
                Text(
                  'Upcoming Wheel : Apr 27',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryDark),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.primaryDark),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.title,
    required this.memberCount,
    required this.onOpen,
    required this.onJoin,
  });

  final String title;
  final int memberCount;
  final VoidCallback onOpen;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return AjoCard(
      radius: 20,
      borderColor: const Color(0xFFF0E2C9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              GestureDetector(
                onTap: onOpen,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDE6E0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Open',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.blur_circular_outlined,
                  size: 18, color: AppColors.text),
              const SizedBox(width: 6),
              Text(
                '$memberCount Members',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const _SmallMemberCluster(),
              const Spacer(),
              FilledButton(
                onPressed: onJoin,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                ),
                child: const Text('Join Group'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallMemberCluster extends StatelessWidget {
  const _SmallMemberCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 28,
      child: Stack(
        children: [
          const Positioned(
              left: 0, child: AjoAvatar(name: 'Ematony', radius: 14)),
          const Positioned(
              left: 18, child: AjoAvatar(name: 'Mary', radius: 14)),
          const Positioned(
              left: 36, child: AjoAvatar(name: 'David', radius: 14)),
          Positioned(
            left: 58,
            top: 4,
            child: Text('+9',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.text)),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AjoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: AppColors.mutedText)),
          ),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SwitchPill extends StatelessWidget {
  const _SwitchPill({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : const Color(0xFFDFE5DA),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFF9F1DF),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String Function(String value)? itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(itemLabelBuilder?.call(e) ?? e),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary),
  );
}
