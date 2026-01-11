import 'package:auto_manager/databases/repo/Activity/activity_hybrid_repo.dart';

// contract for activity data operations
abstract class AbstractActivityRepo {
  Future<List<Map<String, dynamic>>> getActivities();
  Future<bool> insertActivity(Map<String, dynamic> activity);

  static AbstractActivityRepo? _carInstance;

  // factory that returns the hybrid implementation
  static AbstractActivityRepo getInstance() {
    _carInstance ??= ActivityHybridRepo();
    return _carInstance!;
  }
}
