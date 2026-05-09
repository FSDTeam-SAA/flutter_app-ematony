import 'package:flutter/foundation.dart';

import '../../core/models/group_model.dart';
import '../groups/groups_repository.dart';

class WheelRotationItem {
  WheelRotationItem({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.positionNumber,
    required this.membershipRole,
  });

  final String userId;
  final String name;
  final String? avatarUrl;
  final int positionNumber;
  final String membershipRole;

  factory WheelRotationItem.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : <String, dynamic>{};
    final avatar = user['avatar'];
    String? avatarUrl;
    if (avatar is Map) {
      avatarUrl = avatar['url']?.toString();
    } else if (avatar is String && avatar.isNotEmpty) {
      avatarUrl = avatar;
    }
    return WheelRotationItem(
      userId: (user['_id'] ?? '').toString(),
      name: (user['name'] ?? user['firstName'] ?? 'Member').toString(),
      avatarUrl: (avatarUrl?.isNotEmpty == true) ? avatarUrl : null,
      positionNumber: (json['positionNumber'] as num?)?.toInt() ?? 0,
      membershipRole: (json['membershipRole'] ?? 'member').toString(),
    );
  }
}

class WheelController extends ChangeNotifier {
  WheelController({required GroupsRepository repository})
      : _repository = repository;

  final GroupsRepository _repository;

  bool isLoadingGroups = false;
  bool isLoadingWheel = false;
  bool isSpinning = false;
  String? error;

  List<GroupModel> groups = [];
  GroupModel? selectedGroup;

  List<WheelRotationItem> rotations = [];
  int totalMembers = 0;
  WheelRotationItem? currentMonthWinner;
  WheelRotationItem? lastWinner;
  bool canSpin = false;
  bool isOwner = false;
  Map<String, dynamic> spinWindow = const {};

  Future<void> loadGroups() async {
    if (isLoadingGroups) return;
    isLoadingGroups = true;
    error = null;
    notifyListeners();
    try {
      groups = await _repository.listMyGroups();
      if (selectedGroup == null && groups.isNotEmpty) {
        await _selectAndLoad(groups.first);
        return;
      }
      if (selectedGroup != null) {
        // refresh in case the cached selection no longer exists
        final match = groups.firstWhere(
          (g) => g.id == selectedGroup!.id,
          orElse: () => groups.isNotEmpty ? groups.first : selectedGroup!,
        );
        if (match.id != selectedGroup!.id) {
          await _selectAndLoad(match);
          return;
        }
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingGroups = false;
      notifyListeners();
    }
  }

  Future<void> selectGroup(GroupModel group) async {
    if (selectedGroup?.id == group.id) return;
    await _selectAndLoad(group);
  }

  Future<void> _selectAndLoad(GroupModel group) async {
    selectedGroup = group;
    rotations = [];
    totalMembers = 0;
    currentMonthWinner = null;
    lastWinner = null;
    canSpin = false;
    isOwner = false;
    notifyListeners();
    await _loadWheel(group.id);
  }

  Future<void> _loadWheel(String groupId) async {
    isLoadingWheel = true;
    notifyListeners();
    try {
      final data = await _repository.getGroupWheel(groupId);
      final rawRotations = data['rotations'];
      if (rawRotations is List) {
        rotations = rawRotations
            .whereType<Map<String, dynamic>>()
            .map(WheelRotationItem.fromJson)
            .toList();
      }
      totalMembers = (data['totalMembers'] as num?)?.toInt() ?? rotations.length;

      final winnerRaw = data['currentMonthWinner'];
      currentMonthWinner = _winnerFromJson(winnerRaw);

      final recentRaw = data['recentWinners'];
      if (recentRaw is List && recentRaw.isNotEmpty) {
        lastWinner = _winnerFromJson(recentRaw.first) ?? currentMonthWinner;
      } else {
        lastWinner = currentMonthWinner;
      }

      canSpin = data['canSpin'] == true;
      isOwner = data['isOwner'] == true;
      final window = data['spinWindow'];
      spinWindow = window is Map<String, dynamic> ? window : const {};

      // Refresh group's contributionAmount/maxMembers from response if richer
      final groupRaw = data['group'];
      if (groupRaw is Map<String, dynamic> && selectedGroup != null) {
        final updated = GroupModel.fromJson(groupRaw)
          ..membersCount = totalMembers;
        selectedGroup = updated;
      } else if (selectedGroup != null) {
        selectedGroup!.membersCount = totalMembers;
      }
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoadingWheel = false;
      notifyListeners();
    }
  }

  WheelRotationItem? _winnerFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) return null;
    final user = raw['userId'] is Map<String, dynamic>
        ? raw['userId'] as Map<String, dynamic>
        : (raw['user'] is Map<String, dynamic>
            ? raw['user'] as Map<String, dynamic>
            : <String, dynamic>{});
    if (user.isEmpty) return null;
    final avatar = user['avatar'];
    String? avatarUrl;
    if (avatar is Map) {
      avatarUrl = avatar['url']?.toString();
    } else if (avatar is String && avatar.isNotEmpty) {
      avatarUrl = avatar;
    }
    return WheelRotationItem(
      userId: (user['_id'] ?? '').toString(),
      name: (user['name'] ?? 'Member').toString(),
      avatarUrl: (avatarUrl?.isNotEmpty == true) ? avatarUrl : null,
      positionNumber: 0,
      membershipRole: 'member',
    );
  }

  Future<Map<String, dynamic>?> spin() async {
    final id = selectedGroup?.id;
    if (id == null || isSpinning || !canSpin) return null;
    isSpinning = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.spinGroupWheel(id);
      await _loadWheel(id);
      return result;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isSpinning = false;
      notifyListeners();
    }
  }

  double get currentSavingsPool {
    final group = selectedGroup;
    if (group == null) return 0;
    return group.contributionAmount * (totalMembers > 0 ? totalMembers : 1);
  }

  String formattedSavingsPool() {
    final symbol = (selectedGroup?.currencyCode ?? 'NGN') == 'USD' ? r'$' : '₦';
    final formatted = currentSavingsPool.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$symbol$formatted';
  }
}
