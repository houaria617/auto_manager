import 'package:auto_manager/databases/repo/auth/auth_hybrid_repo.dart';
import 'package:auto_manager/logic/cubits/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages authentication state and operations
/// Location: lib/logic/cubits/auth/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  // Use hybrid repo instead of abstract repo
  final _authRepo = AuthHybridRepo();

  AuthCubit() : super(AuthInitial());

  /// Check if user is already logged in on app start
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
      print('Auth check error: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Login with email and password
  Future<void> login({
    required String username, // This will be email for backend
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
        emit(AuthError('Invalid email or password'));
      }
    } catch (e) {
      print('Login error: $e');
      emit(AuthError('Login failed: ${e.toString()}'));
    }
  }

  /// Signup new user
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
        emit(AuthError('Email already exists or signup failed'));
      }
    } catch (e) {
      print('Signup error: $e');
      emit(AuthError('Signup failed: ${e.toString()}'));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    emit(AuthLoading());
    
    try {
      await _authRepo.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      print('Logout error: $e');
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  /// Verify if token is still valid (optional)
  Future<bool> verifyToken() async {
    return await _authRepo.verifyToken();
  }
}