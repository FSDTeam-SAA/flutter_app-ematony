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
  bool hasSeenOnboarding = false;
  String? errorMessage;

  bool get isAuthenticated => currentUser != null;
  bool get isKycVerified => currentUser?.kycVerified ?? false;

  /// Called once at app start. Restores session and ensures a minimum
  /// splash duration for a professional, smooth experience.
  Future<void> bootstrap() async {
    final startTime = DateTime.now();

    try {
      currentUser = await _repository.restoreUser();
    } catch (_) {
      currentUser = null;
    }

    // If the restored user never finished KYC, treat the saved session as
    // invalid: clear it so the next launch routes them to Login. They have
    // to log in again, at which point the router will send them straight
    // to /kyc/personal-info to complete verification.
    if (currentUser != null && !currentUser!.kycVerified) {
      try {
        await _repository.logout();
      } catch (_) {
        // Best-effort. The local clear in logout() runs even if the network
        // request fails, so the session storage is wiped either way.
      }
      currentUser = null;
    }

    try {
      hasSeenOnboarding = await _repository.hasSeenOnboarding();
    } catch (_) {
      hasSeenOnboarding = false;
    }

    // Ensure splash stays visible for at least 2 seconds for branding
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minDelay = 2000;
    if (elapsed < minDelay) {
      await Future.delayed(Duration(milliseconds: minDelay - elapsed));
    }

    isReady = true;
    notifyListeners();
  }

  void clearError() {
    if (errorMessage == null) return;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    if (hasSeenOnboarding) return;
    hasSeenOnboarding = true;
    await _repository.markOnboardingSeen();
    notifyListeners();
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
    if (isBusy) return false;
    
    isBusy = true;
    errorMessage = null;
    notifyListeners(); // Notify router that we are busy (optional, but good for UI)

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
