import 'dart:io'; // For Platform check
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart'; // <--- NEW IMPORT

// Core/Service Imports
import 'package:auto_manager/core/services/sync_service.dart'; // <--- NEW IMPORT
import 'package:auto_manager/logic/cubits/auth/auth_cubit.dart';
import 'package:auto_manager/logic/cubits/auth/auth_state.dart';

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

// --- NEW WORKMANAGER DISPATCHER ---
@pragma('vm:entry-point') // Mandatory for background tasks
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // This calls the logic that pushes pending SQLite rows to Flask
      await SyncService.performSync();
    } catch (e) {
      print("Background sync failed: $e");
    }
    return Future.value(true);
  });
}

void main() async {
  // Added async
  WidgetsFlutterBinding.ensureInitialized();

  // --- NEW WORKMANAGER INITIALIZATION ---
  // Background tasks don't work on Desktop, so we only init on Mobile
  if (Platform.isAndroid || Platform.isIOS) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false when you publish the app
    );

    // Register a task to run every 15 minutes automatically
    Workmanager().registerPeriodicTask(
      "periodic-sync-task",
      "syncDataTask",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType:
            NetworkType.connected, // Only runs if internet is available
      ),
    );
  }

  // Existing Database Factory for Desktop (Linux/Windows/MacOS)
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

// ... rest of your MainApp and AuthChecker classes remain identical ...
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardCubit>(create: (_) => DashboardCubit()),
        BlocProvider<ProfileCubit>(create: (_) => ProfileCubit()),
        BlocProvider<ClientCubit>(create: (_) => ClientCubit()),
        BlocProvider<RentalCubit>(create: (_) => RentalCubit()..loadRentals()),
        BlocProvider<CarsCubit>(
          create: (context) {
            final cubit = CarsCubit();
            cubit.dashboardCubit = context.read<DashboardCubit>();
            return cubit;
          },
        ),
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()..checkAuthStatus()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const AuthChecker(),
          );
        },
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AuthAuthenticated) {
          return const Dashboard();
        }
        return const LoginScreen();
      },
    );
  }
}
