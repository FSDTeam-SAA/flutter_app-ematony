import 'package:flutter/foundation.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
      : _repository = repository;

  final AuthRepository _repository;

  AppUser? currentUser;
  bool isBusy = false;
  bool isReady = false;
  String? errorMessage;

  bool get isAuthenticated => currentUser != null;
  bool get isKycVerified => currentUser?.kycVerified ?? false;

  /// Called once at app start. Restores session from local storage,
  /// then refreshes the user profile from the server if reachable.
  Future<void> bootstrap() async {
    try {
      currentUser = await _repository.restoreUser();
    } catch (_) {
      currentUser = null;
    } finally {
      isReady = true;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    return _runGuarded(() async {
      final session =
          await _repository.login(email: email, password: password);
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
    try {
      await _repository.logout();
    } finally {
      currentUser = null;
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(AppUser updated) async {
    currentUser = updated;
    await _repository.updateUser(updated);
    notifyListeners();
  }

  Future<void> markKycVerified() async {
    if (currentUser == null) return;
    currentUser = currentUser!.copyWith(kycVerified: true);
    await _repository.updateUser(currentUser!);
    notifyListeners();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Future<bool> _runGuarded(Future<void> Function() task) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await task();
      return true;
    } catch (error) {
      errorMessage = _friendlyMessage(error.toString());
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  /// Strips the leading "Exception: " prefix Dart appends when re-throwing.
  String _friendlyMessage(String raw) {
    if (raw.startsWith('Exception: ')) return raw.substring(11);
    return raw;
  }
}
