// THIS FILE IS USED TO DEFINE AN ABSTRACT
// CLASS FOR ENTITY `Client`, FOLLOWING THE
// ABSTRACT REPOSITORY DESIGN PATTERN.

// import 'vehicle_dummy.dart';
import 'activity_db.dart';

abstract class AbstractActivityRepo {
  Future<List<Map<String, dynamic>>> getActivities();
  Future<bool> insertActivity(Map<String, dynamic> activity);

  static AbstractActivityRepo? _carInstance;

  static AbstractActivityRepo getInstance() {
    // later, ClientDB will replace ClientDummy here:
    _carInstance ??= ActivityDB();
    return _carInstance!;
  }
}
