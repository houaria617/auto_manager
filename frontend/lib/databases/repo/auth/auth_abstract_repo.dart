import 'package:auto_manager/features/auth/data/models/user_model.dart';

// contract for auth operations like login, signup, logout
abstract class AuthAbstractRepo {
  // authenticates user with email and password
  Future<UserModel?> login({
    required String username,
    required String password,
  });

  // creates a new user account
  Future<UserModel?> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  });

  // logs out current user and clears local data
  Future<void> logout();

  // checks if there's an active session
  Future<bool> isLoggedIn();

  // returns current user if logged in
  Future<UserModel?> getCurrentUser();
}
