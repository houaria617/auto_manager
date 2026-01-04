abstract class AbstractAnalyticsRepo {
  Future<Map<String, dynamic>> getStats(String timeframe);
}
