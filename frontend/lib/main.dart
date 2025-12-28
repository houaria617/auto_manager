import 'package:auto_manager/cubit/client_cubit.dart';
import 'package:auto_manager/cubit/dashboard_cubit.dart';
import 'package:auto_manager/cubit/profile_cubit.dart';
import 'package:auto_manager/cubit/rental_cubit.dart';
import 'package:auto_manager/cubit/vehicle_cubit.dart';
import 'package:auto_manager/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
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
        BlocProvider<VehicleCubit>(
          create: (context) =>
              VehicleCubit(dashboardCubit: context.read<DashboardCubit>()),
        ),
        BlocProvider<RentalCubit>(
          create: (context) => RentalCubit(
            dashboardCubit: context.read<DashboardCubit>(),
            clientCubit: context.read<ClientCubit>(),
            vehicleCubit: context.read<VehicleCubit>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      ),
    );
  }
}
