// authentication state classes for auth cubit

import 'package:auto_manager/features/auth/data/models/user_model.dart';

abstract class AuthState {}

// initial state before any auth check
class AuthInitial extends AuthState {}

// loading during auth operations
class AuthLoading extends AuthState {}

// user successfully authenticated with user data
class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

// no active user session
class AuthUnauthenticated extends AuthState {}

// auth operation failed with error message
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
