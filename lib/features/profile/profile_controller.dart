import 'package:flutter/foundation.dart';
import '../auth/auth_models.dart';
import 'profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;

  bool isLoading = false;
  String? error;

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? imageFilePath,
    required Function(AppUser) onSuccess,
  }) async {
    if (isLoading) return;
    
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = await _repository.updateProfile(
        name: name,
        phone: phone,
        bio: bio,
        imageFilePath: imageFilePath,
      );
      onSuccess(user);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String current,
    required String next,
    required String confirm,
  }) async {
    if (isLoading) return false;
    
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _repository.changePassword(
        currentPassword: current,
        newPassword: next,
        confirmPassword: confirm,
      );
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
