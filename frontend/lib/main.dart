import 'dart:io'; // For Platform check

import 'package:auto_manager/databases/repo/auth/auth_db_repo.dart';
import 'package:auto_manager/logic/cubits/auth/auth_cubit.dart';
import 'package:auto_manager/logic/cubits/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Localization Imports
import 'package:auto_manager/l10n/app_localizations.dart';

// Feature Imports
import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:auto_manager/features/Dashboard/dashboard.dart';

// Logic/Cubit Imports
import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/logic/cubits/clients/client_cubit.dart';
import 'package:auto_manager/logic/cubits/dashboard/dashboard_cubit.dart';
import 'package:auto_manager/logic/cubits/clients/profile_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Database Factory for Desktop (Linux/Windows/MacOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // --- 1. Global App Providers (Source 2) ---
        BlocProvider<DashboardCubit>(create: (_) => DashboardCubit()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<ClientCubit>(create: (_) => ClientCubit()),
        BlocProvider<RentalCubit>(
          create: (context) {
            final cubit = RentalCubit()..loadRentals();
            cubit.dashboardCubit = context
                .read<DashboardCubit>(); // Nacer: Inject DashboardCubit
            return cubit;
          },
        ),
        BlocProvider<CarsCubit>(
          create: (context) {
            final cubit = CarsCubit();
            // Inject Dashboard dependency into CarsCubit
            cubit.dashboardCubit = context.read<DashboardCubit>();
            return cubit;
          },
        ),
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),

        // --- 2. Auth Provider (Source 1) ---
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit()..checkAuthStatus(),
        ),
      ],
      // Listen to Locale changes
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            // Localization Setup
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,

            // Navigation Logic: Use AuthChecker instead of hardcoded LoginScreen
            home: const AuthChecker(),
          );
        },
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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is authenticated, go to Dashboard
        if (state is AuthAuthenticated) {
          return const Dashboard();
        }

        // Otherwise (AuthUnauthenticated or Error), show Login screen
        return const LoginScreen();
      },
    );
  }
}
