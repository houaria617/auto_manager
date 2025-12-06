import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_manager/data/repo/auth/auth_abstract_repo.dart';
import 'package:auto_manager/logic/cubits/auth_state.dart';

/// Manages authentication state and operations
/// Location: lib/logic/cubits/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  final AuthAbstractRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial());

  /// Check if user is already logged in on app start
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

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
  }

  /// Login with username and password
  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    final user = await _authRepo.login(
      username: username,
      password: password,
    );

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError('Invalid username or password'));
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
      emit(AuthError('Username already exists or signup failed'));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    emit(AuthLoading());
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }
}