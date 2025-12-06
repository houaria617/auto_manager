import 'dart:io'; // Import this for Platform check
import 'package:auto_manager/logic/cubits/locale/locale_cubit.dart';
import 'package:auto_manager/l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/cubit/profile_cubit.dart';
import 'package:auto_manager/logic/cubits/rental/rental_cubit.dart';
import 'package:auto_manager/logic/cubits/cars/cars_cubit.dart';
import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize Database Factory for Desktop
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
          create: (context) => RentalCubit()..loadRentals(),
        ),
        BlocProvider<CarsCubit>(
          create: (context) {
            final cubit = CarsCubit();
            cubit.dashboardCubit = context.read<DashboardCubit>();
            return cubit;
          },
        ),
        BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}
