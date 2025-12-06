import 'dart:io'; // Import this for Platform check
// import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
// import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
// import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/cubit/profile_cubit.dart';
import 'package:auto_manager/cubit/rental_cubit.dart';
import 'package:auto_manager/cubit/vehicle_cubit.dart';
import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // ADD THIS BLOCK: Initialize Database Factory for Desktop
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
        BlocProvider<DashboardCubit>(create: (_) => DashboardCubit()),
        BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
        BlocProvider<ClientCubit>(create: (context) => ClientCubit()),
        BlocProvider<RentalCubit>(
          create: (context) => RentalCubit(
            dashboardCubit: context.read<DashboardCubit>(),
            clientCubit: context.read<ClientCubit>(),
          ),
        ),
        BlocProvider<VehicleCubit>(
          create: (context) =>
              VehicleCubit(dashboardCubit: context.read<DashboardCubit>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
