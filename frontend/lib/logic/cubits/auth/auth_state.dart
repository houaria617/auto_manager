import 'package:auto_manager/features/auth/data/models/user_model.dart';

/// Authentication states for AuthCubit
/// Location: lib/logic/cubits/auth_state.dart
abstract class AuthState {}

/// Initial state when app starts
class AuthInitial extends AuthState {}

/// Loading state during login/signup/logout
class AuthLoading extends AuthState {}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final UserModel user;

  AuthAuthenticated(this.user);
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {}

/// Error occurred during authentication
class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
