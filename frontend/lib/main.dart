import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:auto_manager/features/Dashboard/dashboard.dart';
import 'package:auto_manager/logic/cubits/auth_cubit.dart';
import 'package:auto_manager/logic/cubits/auth_state.dart';
import 'package:auto_manager/data/repo/auth/auth_db_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Provide AuthCubit to entire app and check auth status immediately
      create: (context) => AuthCubit(AuthDbRepo())..checkAuthStatus(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthChecker(),
      ),
    );
  }
}

/// Checks authentication status and routes to appropriate screen
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Show loading spinner while checking authentication
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is authenticated, go to Dashboard
        if (state is AuthAuthenticated) {
          return const Dashboard();
        }

        // Otherwise, show Login screen
        return const LoginScreen();
      },
    );
  }
}