// state classes for analytics cubit

abstract class AnalyticsState {}

// initial state before any load
class AnalyticsInitial extends AnalyticsState {}

// loading analytics data
class AnalyticsLoading extends AnalyticsState {}

// analytics loaded with all calculated metrics
class AnalyticsLoaded extends AnalyticsState {
  final double totalRevenue;
  final int totalRentals;
  final int avgDurationDays;
  final List<Map<String, dynamic>> topCars;
  final int totalClients;
  final int activeClients;
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

// error occurred during analytics load
class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}
