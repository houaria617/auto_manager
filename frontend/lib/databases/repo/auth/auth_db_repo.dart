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
      // Validate that fields are not empty
      if (username.isEmpty || password.isEmpty) {
        print('❌ Email and password cannot be empty');
        return null;
      }

      // In offline mode, we cannot validate credentials without a password database
      // We can only check if the provided email matches a previously stored email
      // If no user is stored locally, we cannot authenticate in offline mode
      
      // Try to get stored user data
      final storedUserId = await _prefsManager.getUserId();
      final storedUsername = await _prefsManager.getUsername();
      final storedUserData = await _prefsManager.getFullUserData();

      // If no user is stored, we cannot authenticate in offline mode
      if (storedUserId == null || storedUsername == null) {
        print('❌ No stored user found. Cannot login in offline mode without previous login.');
        print('💡 Please connect to the internet and login to your account first.');
        return null;
      }

      // Check if the email matches the stored user (case-insensitive)
      if (storedUserData?.email != null && 
          storedUserData!.email!.toLowerCase() != username.toLowerCase()) {
        print('❌ Invalid email or password');
        return null;
      }

      // Alternative: Allow login with stored username for offline mode
      // This assumes the username/email stored matches what they're trying to login with
      print('⚠️  Offline mode: Limited verification (no password check available)');
      print('✅ Offline login successful using stored user data');
      
      return storedUserData;
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
