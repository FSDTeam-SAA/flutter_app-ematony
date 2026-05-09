import 'package:flutter/foundation.dart';
import '../../core/models/payment_model.dart';
import 'wallet_repository.dart';

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
    if (isLoading) return;
    
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
