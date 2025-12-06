import 'dart:io';
import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/cubit/profile_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:auto_manager/features/Dashboard/dashboard.dart';
import 'package:auto_manager/logic/cubits/auth_cubit.dart';
import 'package:auto_manager/logic/cubits/auth_state.dart';
import 'package:auto_manager/data/repo/auth/auth_db_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
        BlocProvider(create: (_) => DashboardCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(create: (_) => ClientCubit()),
        BlocProvider(create: (_) => RentalCubit()..loadRentals()),
        BlocProvider(
          create: (context) {
            final cubit = CarsCubit();
            cubit.dashboardCubit = context.read<DashboardCubit>();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(create: (_) => AuthCubit(AuthDbRepo())..checkAuthStatus()),
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

/// This widget decides where to go depending on auth status
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
