import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();

  AnalyticsCubit() : super(AnalyticsInitial());

  Future<void> loadStats(String timeframe) async {
    emit(AnalyticsLoading());
    try {
      // 1. Fetch data and cast safely to Map<String, dynamic>
      // This casting prevents type errors later in the code
      final rawRentals = await _rentalRepo.getData();
      final rawCars = await _carRepo.getData();
      final rawClients = await _clientRepo.getAllClients();

      final List<Map<String, dynamic>> allRentals =
          List<Map<String, dynamic>>.from(rawRentals);
      final List<Map<String, dynamic>> allCars =
          List<Map<String, dynamic>>.from(rawCars);
      final List<Map<String, dynamic>> allClients =
          List<Map<String, dynamic>>.from(rawClients);

      // 2. Define Date Filters
      final now = DateTime.now();
      DateTime startDate;

      if (timeframe == 'This Week') {
        // Find last Monday (or today if it's Monday)
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
      } else if (timeframe == 'This Month') {
        startDate = DateTime(now.year, now.month, 1);
      } else {
        startDate = DateTime(2000);
      }

      // 3. Filter Rentals
      List<Map<String, dynamic>> filteredRentals = allRentals.where((rental) {
        final dateStr = rental['date_from']?.toString() ?? '';
        final rentalDate = DateTime.tryParse(dateStr) ?? DateTime(1900);
        return rentalDate.isAfter(startDate) ||
            rentalDate.isAtSameMomentAs(startDate);
      }).toList();

      // 4. Calculate Key Metrics
      double totalRevenue = 0.0;
      int totalDuration = 0;
      Set<int> activeClientIds = {};
      Map<int, int> carPopularity = {};
      List<double> chartData = List.filled(7, 0.0);

      for (var rental in filteredRentals) {
        // Revenue
        double amount = (rental['total_amount'] is int)
            ? (rental['total_amount'] as int).toDouble()
            : (rental['total_amount'] as double? ?? 0.0);
        totalRevenue += amount;

        // Duration
        final start =
            DateTime.tryParse(rental['date_from']?.toString() ?? '') ?? now;
        final end =
            DateTime.tryParse(rental['date_to']?.toString() ?? '') ?? now;
        int days = end.difference(start).inDays;
        if (days < 1) days = 1;
        totalDuration += days;

        // Active Clients
        if (rental['client_id'] != null) {
          activeClientIds.add(rental['client_id'] as int);
        }

        // Car Count
        if (rental['car_id'] != null) {
          int cId = rental['car_id'] as int;
          carPopularity[cId] = (carPopularity[cId] ?? 0) + 1;
        }

        // Chart Data (Populate for "This Week")
        if (timeframe == 'This Week') {
          int dayIndex = start.weekday - 1;
          if (dayIndex >= 0 && dayIndex < 7) {
            chartData[dayIndex] += amount;
          }
        } else {
          int dayIndex = start.weekday - 1;
          if (dayIndex >= 0 && dayIndex < 7) {
            chartData[dayIndex] += amount;
          }
        }
      }

      int avgDuration = filteredRentals.isEmpty
          ? 0
          : (totalDuration / filteredRentals.length).round();

      // 5. Calculate Top Cars
      List<Map<String, dynamic>> topCarsList = [];

      var sortedCarIds = carPopularity.keys.toList()
        ..sort((a, b) => carPopularity[b]!.compareTo(carPopularity[a]!));

      int rank = 1;
      for (var id in sortedCarIds) {
        if (rank > 3) break;

        // --- FIX IS HERE ---
        // Explicitly typed orElse map
        final carObj = allCars.firstWhere(
          (c) => c['id'] == id,
          orElse: () => <String, dynamic>{'name': 'Unknown Car', 'plate': ''},
        );

        topCarsList.add({
          'name': "${carObj['name']} ${carObj['plate']}",
          'rentals': carPopularity[id],
          'rank': rank,
        });
        rank++;
      }

      // 6. Emit Data
      emit(
        AnalyticsLoaded(
          totalRevenue: totalRevenue,
          totalRentals: filteredRentals.length,
          avgDurationDays: avgDuration,
          topCars: topCarsList,
          totalClients: allClients.length,
          activeClients: activeClientIds.length,
          revenueChartData: chartData,
        ),
      );
    } catch (e) {
      // It is helpful to print the error to console to debug specific issues
      print("Analytics Error: $e");
      emit(AnalyticsError("Failed to calculate stats: $e"));
    }
  }
}
