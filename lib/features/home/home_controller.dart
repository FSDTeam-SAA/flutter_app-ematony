import 'package:flutter/foundation.dart';
import '../../core/models/group_model.dart';
import '../../core/models/payment_model.dart';
import 'home_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController({required HomeRepository repository})
    : _repository = repository;

  final HomeRepository _repository;

  bool isLoading = false;
  List<GroupModel> groups = [];
  List<PaymentModel> recentTransactions = [];
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
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
