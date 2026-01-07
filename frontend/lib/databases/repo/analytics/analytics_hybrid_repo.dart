import 'dart:convert';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/databases/repo/analytics/analytics_abstract.dart';
import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';

class AnalyticsHybridRepo implements AbstractAnalyticsRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractRentalRepo rentalRepo;
  final AbstractCarRepo carRepo;
  final AbstractClientRepo clientRepo;

  AnalyticsHybridRepo(this.rentalRepo, this.carRepo, this.clientRepo);

  @override
  Future<Map<String, dynamic>> getStats(String timeframe) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.get(
          Uri.parse(
            '$baseUrl/analytics/stats?agency_id=1&timeframe=$timeframe',
          ),
        );
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {}
    }
    // Offline: Compute locally
    return await _computeStatsLocally(timeframe);
  }

  Future<Map<String, dynamic>> _computeStatsLocally(String timeframe) async {
    // Fetch data from local repos
    final rawRentals = await rentalRepo.getData();
    final rawCars = await carRepo.getData();
    final rawClients = await clientRepo.getAllClients();

    final List<Map<String, dynamic>> allRentals =
        List<Map<String, dynamic>>.from(rawRentals);
    final List<Map<String, dynamic>> allCars = List<Map<String, dynamic>>.from(
      rawCars,
    );
    final List<Map<String, dynamic>> allClients =
        List<Map<String, dynamic>>.from(rawClients);

    // Define Date Filters
    final now = DateTime.now();
    DateTime startDate;

    if (timeframe == 'This Week') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else if (timeframe == 'This Month') {
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(2000);
    }

    // Filter Rentals
    List<Map<String, dynamic>> filteredRentals = allRentals.where((rental) {
      final dateStr = rental['date_from']?.toString() ?? '';
      final rentalDate = DateTime.tryParse(dateStr) ?? DateTime(1900);
      return rentalDate.isAfter(startDate) ||
          rentalDate.isAtSameMomentAs(startDate);
    }).toList();

    // Calculate Key Metrics
    double totalRevenue = 0.0;
    int totalDuration = 0;
    Set<int> activeClientIds = {};
    Map<int, int> carPopularity = {};
    List<double> chartData = List.filled(7, 0.0);

    for (var rental in filteredRentals) {
      double amount = (rental['total_amount'] is int)
          ? (rental['total_amount'] as int).toDouble()
          : (rental['total_amount'] as double? ?? 0.0);
      totalRevenue += amount;

      final start =
          DateTime.tryParse(rental['date_from']?.toString() ?? '') ?? now;
      final end = DateTime.tryParse(rental['date_to']?.toString() ?? '') ?? now;
      int days = end.difference(start).inDays;
      if (days < 1) days = 1;
      totalDuration += days;

      if (rental['client_id'] != null) {
        activeClientIds.add(rental['client_id'] as int);
      }

      if (rental['car_id'] != null) {
        int cId = rental['car_id'] as int;
        carPopularity[cId] = (carPopularity[cId] ?? 0) + 1;
      }

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

    // Calculate Top Cars
    List<Map<String, dynamic>> topCarsList = [];

    var sortedCarIds = carPopularity.keys.toList()
      ..sort((a, b) => carPopularity[b]!.compareTo(carPopularity[a]!));

    int rank = 1;
    for (var id in sortedCarIds) {
      if (rank > 3) break;

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

    return {
      'totalRevenue': totalRevenue,
      'totalRentals': filteredRentals.length,
      'avgDurationDays': avgDuration,
      'topCars': topCarsList,
      'totalClients': allClients.length,
      'activeClients': activeClientIds.length,
      'revenueChartData': chartData,
    };
  }
}
