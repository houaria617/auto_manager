import 'package:auto_manager/databases/repo/auth/auth_abstract_repo.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:auto_manager/features/auth/data/models/user_model.dart';

/// SharedPreferences-only implementation of authentication repository
/// NO database operations - just validates and stores in SharedPreferences
/// Location: lib/data/repo/auth/auth_db_repo.dart
class AuthDbRepo implements AuthAbstractRepo {
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      // Simple validation - just check if fields are not empty
      if (username.isEmpty || password.isEmpty) {
        return null;
      }

      // In a real app, you'd check credentials against a backend API
      // For now, we just accept any non-empty credentials

      // Generate a simple user ID (you can use timestamp or random)
      final userId = DateTime.now().millisecondsSinceEpoch;

      // Create user model
      final user = UserModel(id: userId, username: username);

      // Save to SharedPreferences
      await _prefsManager.saveUserData(
        userId: user.id,
        username: user.username,
      );

      return user;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  @override
  Future<UserModel?> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  }) async {
    try {
      // Simple validation
      if (username.isEmpty || password.isEmpty) {
        return null;
      }

      // Generate a unique user ID
      final userId = DateTime.now().millisecondsSinceEpoch;

      // Create user model
      final user = UserModel(
        id: userId,
        username: username,
        companyName: companyName,
        email: email,
        phone: phone,
      );

      // Save to SharedPreferences
      await _prefsManager.saveUserData(
        userId: user.id,
        username: user.username,
      );

      return user;
    } catch (e) {
      print('Signup error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _prefsManager.clearUserData();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _prefsManager.isLoggedIn();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = await _prefsManager.getUserId();
      final username = await _prefsManager.getUsername();

      if (userId == null || username == null) {
        return null;
      }

      // Return user model with stored data
      return UserModel(id: userId, username: username);
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
}
