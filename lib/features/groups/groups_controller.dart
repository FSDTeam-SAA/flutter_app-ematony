import 'package:flutter/foundation.dart';
import '../../core/models/group_model.dart';
import '../wheel/wheel_controller.dart';
import 'groups_repository.dart';

class GroupPreview {
  GroupPreview({required this.rotations, required this.nextWheelDate});

  final List<WheelRotationItem> rotations;
  final DateTime? nextWheelDate;
}

class GroupsController extends ChangeNotifier {
  GroupsController({required GroupsRepository repository})
      : _repository = repository;

  final GroupsRepository _repository;

  bool isLoading = false;
  bool isCreating = false;
  bool isJoining = false;
  List<GroupModel> activeGroups = [];
  List<GroupModel> requestGroups = [];
  Map<String, GroupPreview> previews = {};
  String? error;
  String? createdInviteCode;

  Future<void> load() async {
    if (isLoading) return;
    
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.listMyGroups(),
        _repository.listGroupRequests(),
      ]);
      activeGroups = results[0];
      requestGroups = results[1];

      previews = {};
      if (activeGroups.isNotEmpty) {
        final fetched = await Future.wait(
          activeGroups.map((g) async {
            try {
              final data = await _repository.getGroupWheel(g.id);
              return MapEntry(g.id, _previewFromWheel(data, g));
            } catch (_) {
              return MapEntry(g.id, GroupPreview(rotations: const [], nextWheelDate: null));
            }
          }),
        );
        previews = Map.fromEntries(fetched);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  GroupPreview _previewFromWheel(Map<String, dynamic> data, GroupModel group) {
    final rotationsRaw = data['rotations'];
    final rotations = (rotationsRaw is List)
        ? rotationsRaw
            .whereType<Map<String, dynamic>>()
            .map(WheelRotationItem.fromJson)
            .toList()
        : <WheelRotationItem>[];
    final total =
        (data['totalMembers'] as num?)?.toInt() ?? rotations.length;
    if (total > 0) group.membersCount = total;

    DateTime? next;
    final window = data['spinWindow'];
    if (window is Map<String, dynamic>) {
      final startDay = (window['startDay'] as num?)?.toInt() ?? 25;
      final today = (window['today'] as num?)?.toInt() ?? DateTime.now().day;
      final now = DateTime.now();
      next = today > startDay
          ? DateTime(now.year, now.month + 1, startDay)
          : DateTime(now.year, now.month, startDay);
    }
    return GroupPreview(rotations: rotations, nextWheelDate: next);
  }

  Future<void> loadDetail(String id) async {
    // Details are usually handled in the screen or a specialized sub-controller
    notifyListeners();
  }

  Future<bool> createGroup({
    required String name,
    required String amount,
    required String frequency,
    required String maxMembers,
    required String cycleDuration,
    required bool autoPayments,
  }) async {
    if (isCreating) return false;
    
    isCreating = true;
    error = null;
    createdInviteCode = null;
    notifyListeners();
    try {
      final parsedAmount = double.tryParse(
              amount.replaceAll('₦', '').replaceAll(',', '').trim()) ??
          1000;
      final parsedMembers = int.tryParse(maxMembers.trim()) ?? 10;
      final code = await _repository.createGroup(
        name: name,
        amount: parsedAmount,
        frequency: frequency,
        maxMembers: parsedMembers,
        autoPayments: autoPayments,
      );
      createdInviteCode = code;
      await load();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  Future<String?> joinByCode(String code) async {
    if (isJoining) return null;
    
    isJoining = true;
    error = null;
    notifyListeners();
    try {
      final groupId = await _repository.joinByCode(code);
      await load();
      return groupId;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isJoining = false;
      notifyListeners();
    }
  }

  Future<bool> joinGroup(String groupId) async => true;
}
