import 'package:auto_manager/features/auth/data/models/user_model.dart';

/// Abstract repository for authentication operations
/// Defines contract for login, signup, logout
/// Location: lib/data/repo/auth/auth_abstract_repo.dart
abstract class AuthAbstractRepo {
  /// Login with username and password
  /// Returns UserModel if successful, null if failed
  Future<UserModel?> login({
    required String username,
    required String password,
  });

  /// Register new user
  /// Returns UserModel if successful, null if failed
  Future<UserModel?> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  });

  /// Logout current user
  /// Clears shared preferences
  Future<void> logout();

  /// Check if user is currently logged in
  Future<bool> isLoggedIn();

  /// Get current logged in user
  /// Returns UserModel if logged in, null otherwise
  Future<UserModel?> getCurrentUser();
}
