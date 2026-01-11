import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart';

import 'package:auto_manager/core/services/sync_service.dart';
import 'package:auto_manager/logic/cubits/auth/auth_cubit.dart';
import 'package:auto_manager/logic/cubits/auth/auth_state.dart';

import 'package:auto_manager/l10n/app_localizations.dart';

import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:auto_manager/features/Dashboard/dashboard.dart';

import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/logic/cubits/clients/client_cubit.dart';
import 'package:auto_manager/logic/cubits/dashboard/dashboard_cubit.dart';
import 'package:auto_manager/logic/cubits/clients/profile_cubit.dart';

// workmanager needs this entry point for background tasks
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // pushes any pending local changes to the server
      await SyncService.performSync();
    } catch (e) {
      print("Background sync failed: $e");
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // workmanager only works on mobile platforms
  if (Platform.isAndroid || Platform.isIOS) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    // schedule automatic sync every 15 minutes when online
    Workmanager().registerPeriodicTask(
      "periodic-sync-task",
      "syncDataTask",
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  // desktop platforms need the ffi database factory
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MainApp());
}

// root widget that sets up all the bloc providers
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
        // cars cubit needs dashboard reference for updating stats
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
      // rebuild the app when locale changes
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

// decides which screen to show based on auth state
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // show spinner while checking auth status
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // user is logged in, show dashboard
        if (state is AuthAuthenticated) {
          return const Dashboard();
        }
        // not authenticated, show login
        return const LoginScreen();
      },
    );
  }
}
