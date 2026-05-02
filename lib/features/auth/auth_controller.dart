import 'package:flutter/foundation.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  AppUser? currentUser;
  bool isBusy = false;
  bool isReady = false;
  String? errorMessage;

  bool get isAuthenticated => currentUser != null;
  bool get isKycVerified => currentUser?.kycVerified ?? false;

  Future<void> bootstrap() async {
    currentUser = await _repository.restoreUser();
    isReady = true;
    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _runGuarded(() async {
      final session = await _repository.login(email: email, password: password);
      currentUser = session.user;
    });
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    return _runGuarded(() async {
      final session = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );
      currentUser = session.user;
    });
  }

  Future<bool> forgotPassword(String email) {
    return _runGuarded(() => _repository.forgotPassword(email));
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) {
    return _runGuarded(
      () => _repository.resetPassword(
        email: email,
        otp: otp,
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    isBusy = true;
    notifyListeners();
    await _repository.logout();
    currentUser = null;
    isBusy = false;
    notifyListeners();
  }

  Future<void> updateProfile(AppUser updated) async {
    currentUser = updated;
    await _repository.updateUser(updated);
    notifyListeners();
  }

  Future<void> markKycVerified() async {
    if (currentUser == null) return;
    currentUser = AppUser(
      id: currentUser!.id,
      name: currentUser!.name,
      email: currentUser!.email,
      role: currentUser!.role,
      phone: currentUser!.phone,
      kycVerified: true,
    );
    await _repository.updateUser(currentUser!);
    notifyListeners();
  }

  Future<bool> _runGuarded(Future<void> Function() task) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await task();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
