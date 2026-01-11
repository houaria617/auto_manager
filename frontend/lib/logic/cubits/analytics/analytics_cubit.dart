// loads and calculates analytics data for reports screen

import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:auto_manager/databases/repo/rentals/rental_hybrid_repo.dart';
import 'package:auto_manager/databases/repo/analytics/analytics_hybrid_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  // repo instances for aggregating data
  final _rentalRepo = RentalHybridRepo();
  final _carRepo = AbstractCarRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();
  late final _analyticsRepo = AnalyticsHybridRepo(
    _rentalRepo,
    _carRepo,
    _clientRepo,
  );

  AnalyticsCubit() : super(AnalyticsInitial());

  // calculates stats for the selected timeframe
  Future<void> loadStats(String timeframe) async {
    emit(AnalyticsLoading());
    try {
      final stats = await _analyticsRepo.getStats(timeframe);
      emit(
        AnalyticsLoaded(
          totalRevenue: stats['totalRevenue'],
          totalRentals: stats['totalRentals'],
          avgDurationDays: stats['avgDurationDays'],
          topCars: List<Map<String, dynamic>>.from(stats['topCars']),
          totalClients: stats['totalClients'],
          activeClients: stats['activeClients'],
          revenueChartData: List<double>.from(stats['revenueChartData']),
        ),
      );
    } catch (e) {
      print("analytics error: $e");
      emit(AnalyticsError("failed to load stats: $e"));
    }
  }
}
