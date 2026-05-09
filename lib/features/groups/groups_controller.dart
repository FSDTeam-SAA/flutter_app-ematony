import 'package:flutter/foundation.dart';
import '../../core/models/group_model.dart';
import 'groups_repository.dart';

class GroupsController extends ChangeNotifier {
  GroupsController({required GroupsRepository repository})
      : _repository = repository;

  final GroupsRepository _repository;

  bool isLoading = false;
  bool isCreating = false;
  bool isJoining = false;
  List<GroupModel> activeGroups = [];
  List<GroupModel> requestGroups = [];
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
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
