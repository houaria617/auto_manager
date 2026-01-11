import 'package:auto_manager/databases/repo/auth/auth_abstract_repo.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:auto_manager/features/auth/data/models/user_model.dart';

// local auth implementation using shared preferences only
class AuthDbRepo implements AuthAbstractRepo {
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    try {
      // basic validation
      if (username.isEmpty || password.isEmpty) {
        print('❌ Email and password cannot be empty');
        return null;
      }

      // check for previously stored user
      final storedUserId = await _prefsManager.getUserId();
      final storedUsername = await _prefsManager.getUsername();
      final storedUserData = await _prefsManager.getFullUserData();

      // cant login offline without previous session
      if (storedUserId == null || storedUsername == null) {
        print(
          '❌ No stored user found. Cannot login in offline mode without previous login.',
        );
        print(
          '💡 Please connect to the internet and login to your account first.',
        );
        return null;
      }

      // verify email matches stored user
      if (storedUserData?.email != null &&
          storedUserData!.email!.toLowerCase() != username.toLowerCase()) {
        print('❌ Invalid email or password');
        return null;
      }

      // offline mode cant verify password, just check identity
      print(
        '⚠️  Offline mode: Limited verification (no password check available)',
      );
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
      if (username.isEmpty || password.isEmpty) {
        return null;
      }

      // generate local user id
      final userId = DateTime.now().millisecondsSinceEpoch;

      final user = UserModel(
        id: userId,
        username: username,
        companyName: companyName,
        email: email,
        phone: phone,
      );

      // persist user locally
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

      return UserModel(id: userId, username: username);
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
}
