import 'dart:convert';
import 'package:auto_manager/databases/repo/rentals/rental_repository.dart';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/databases/repo/analytics/analytics_abstract.dart';
import 'package:auto_manager/databases/repo/Car/car_abstract.dart';
import 'package:auto_manager/databases/repo/Client/client_abstract.dart';

// calculates analytics stats from local data or server
class AnalyticsHybridRepo implements AbstractAnalyticsRepo {
  final String baseUrl = 'http://localhost:5000';
  final AbstractRentalRepo rentalRepo;
  final AbstractCarRepo carRepo;
  final AbstractClientRepo clientRepo;

  AnalyticsHybridRepo(this.rentalRepo, this.carRepo, this.clientRepo);

  @override
  Future<Map<String, dynamic>> getStats(String timeframe) async {
    // try server first if online
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
    // fall back to local calculation when offline
    return await _computeStatsLocally(timeframe);
  }

  // crunches the numbers from local sqlite data
  Future<Map<String, dynamic>> _computeStatsLocally(String timeframe) async {
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

    // figure out the date range based on timeframe
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

    // filter rentals to selected timeframe
    List<Map<String, dynamic>> filteredRentals = allRentals.where((rental) {
      final dateStr = rental['date_from']?.toString() ?? '';
      final rentalDate = DateTime.tryParse(dateStr) ?? DateTime(1900);
      return rentalDate.isAfter(startDate) ||
          rentalDate.isAtSameMomentAs(startDate);
    }).toList();

    // calculate metrics from filtered rentals
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

      // calculate rental duration in days
      final start =
          DateTime.tryParse(rental['date_from']?.toString() ?? '') ?? now;
      final end = DateTime.tryParse(rental['date_to']?.toString() ?? '') ?? now;
      int days = end.difference(start).inDays;
      if (days < 1) days = 1;
      totalDuration += days;

      // track which clients were active
      if (rental['client_id'] != null) {
        activeClientIds.add(rental['client_id'] as int);
      }

      // count rentals per car for popularity ranking
      if (rental['car_id'] != null) {
        int cId = rental['car_id'] as int;
        carPopularity[cId] = (carPopularity[cId] ?? 0) + 1;
      }

      // add to daily chart data
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

    // build top 3 most popular cars list
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
