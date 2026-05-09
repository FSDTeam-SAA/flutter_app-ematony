import 'package:flutter/foundation.dart';
import '../../core/models/group_model.dart';
import '../../core/models/payment_model.dart';
import '../wheel/wheel_controller.dart';
import 'home_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController({required HomeRepository repository})
      : _repository = repository;

  final HomeRepository _repository;

  bool isLoading = false;
  List<GroupModel> groups = [];
  List<PaymentModel> recentTransactions = [];
  List<WheelRotationItem> firstGroupRotations = [];
  DateTime? nextWheelDate;
  String? error;

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.fetchMyGroups(),
        _repository.fetchRecentTransactions(),
      ]);
      groups = results[0] as List<GroupModel>;
      recentTransactions = results[1] as List<PaymentModel>;

      firstGroupRotations = [];
      nextWheelDate = null;
      if (groups.isNotEmpty) {
        try {
          final wheel = await _repository.fetchGroupWheel(groups.first.id);
          final rotationsRaw = wheel['rotations'];
          if (rotationsRaw is List) {
            firstGroupRotations = rotationsRaw
                .whereType<Map<String, dynamic>>()
                .map(WheelRotationItem.fromJson)
                .toList();
          }
          final total = (wheel['totalMembers'] as num?)?.toInt() ??
              firstGroupRotations.length;
          if (total > 0) {
            groups.first.membersCount = total;
          }
          final window =
              wheel['spinWindow'] is Map<String, dynamic> ? wheel['spinWindow'] as Map<String, dynamic> : null;
          if (window != null) {
            final startDay = (window['startDay'] as num?)?.toInt() ?? 25;
            final today = (window['today'] as num?)?.toInt() ?? DateTime.now().day;
            final now = DateTime.now();
            nextWheelDate = today > startDay
                ? DateTime(now.year, now.month + 1, startDay)
                : DateTime(now.year, now.month, startDay);
          }
        } catch (_) {
          // wheel fetch is best-effort; don't fail home load
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
