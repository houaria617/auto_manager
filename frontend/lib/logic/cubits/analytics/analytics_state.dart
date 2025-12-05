// lib/features/analytics/business_logic/analytics_state.dart

abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final double totalRevenue;
  final int totalRentals;
  final int avgDurationDays;
  final List<Map<String, dynamic>> topCars;
  final int totalClients;
  final int activeClients;

  // NEW: List of values for the 7-day chart (Mon-Sun)
  final List<double> revenueChartData;

  AnalyticsLoaded({
    required this.totalRevenue,
    required this.totalRentals,
    required this.avgDurationDays,
    required this.topCars,
    required this.totalClients,
    required this.activeClients,
    required this.revenueChartData,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}
