// lib/features/analytics/business_logic/analytics_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  AnalyticsCubit() : super(AnalyticsInitial());

  Future<void> loadStats(String timeframe) async {
    emit(AnalyticsLoading());
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      if (timeframe == 'This Week') {
        emit(
          AnalyticsLoaded(
            totalRevenue: 12500.00,
            totalRentals: 120,
            avgDurationDays: 5,
            topCars: [
              {'name': 'Tesla Model 3', 'rentals': 18, 'rank': 1},
              {'name': 'Ford Mustang', 'rentals': 15, 'rank': 2},
              {'name': 'Toyota Camry', 'rentals': 12, 'rank': 3},
            ],
            totalClients: 45,
            activeClients: 11, // treated as "New Clients" for this mock
            // Mock Data for Mon-Sun
            revenueChartData: [200, 450, 300, 500, 250, 600, 400],
          ),
        );
      } else {
        // Mock data for other timeframes
        emit(
          AnalyticsLoaded(
            totalRevenue: 45000.00,
            totalRentals: 300,
            avgDurationDays: 6,
            topCars: [
              {'name': 'Tesla Model 3', 'rentals': 50, 'rank': 1},
              {'name': 'Toyota Camry', 'rentals': 45, 'rank': 2},
              {'name': 'Honda Civic', 'rentals': 40, 'rank': 3},
            ],
            totalClients: 150,
            activeClients: 40,
            revenueChartData: [1000, 3000, 2500, 4000, 2000, 5000, 4500],
          ),
        );
      }
    } catch (e) {
      emit(AnalyticsError("Failed to load analytics"));
    }
  }
}
