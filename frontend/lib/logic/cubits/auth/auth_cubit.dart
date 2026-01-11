// handles authentication state and user login/signup/logout

import 'package:auto_manager/databases/repo/auth/auth_hybrid_repo.dart';
import 'package:auto_manager/logic/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final _authRepo = AuthHybridRepo();

  AuthCubit() : super(AuthInitial());

  // checks stored session on app startup
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      final isLoggedIn = await _authRepo.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authRepo.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  // authenticates user with email and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _authRepo.login(
        username: username,
        password: password,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('invalid email or password'));
      }
    } catch (e) {
      print('login error: $e');
      emit(AuthError('login failed: ${e.toString()}'));
    }
  }

  // creates new user account
  Future<void> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  }) async {
    emit(AuthLoading());

    try {
      final user = await _authRepo.signup(
        username: username,
        password: password,
        companyName: companyName,
        email: email,
        phone: phone,
      );

      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('email already exists or signup failed'));
      }
    } catch (e) {
      print('signup error: $e');
      emit(AuthError('signup failed: ${e.toString()}'));
    }
  }

  // clears session and logs user out
  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await _authRepo.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      print('logout error: $e');
      emit(AuthError('logout failed: ${e.toString()}'));
    }
  }

  /// Verify if token is still valid (optional)
  Future<bool> verifyToken() async {
    return await _authRepo.verifyToken();
  }
}
