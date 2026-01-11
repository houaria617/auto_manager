// contract for analytics data operations
abstract class AbstractAnalyticsRepo {
  Future<Map<String, dynamic>> getStats(String timeframe);
}
