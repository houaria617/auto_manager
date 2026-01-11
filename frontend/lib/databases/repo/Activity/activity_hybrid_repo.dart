import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:auto_manager/databases/dbhelper.dart';
import 'activity_abstract.dart';
import 'activity_db.dart';

// syncs activities between local sqlite and flask api
class ActivityHybridRepo extends AbstractActivityRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractActivityRepo _localRepo = ActivityDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<List<Map<String, dynamic>>> getActivities() async {
    // try to pull latest from server if online
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefsManager.getUserId();
        final token = await _prefsManager.getAuthToken();

        final response = await http
            .get(
              Uri.parse('$baseUrl/analytics/activities?agency_id=$userId'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);

          // replace local activities with fresh server data
          final db = await DBHelper.getDatabase();
          await db.delete('activity');

          for (var item in data) {
            final Map<String, dynamic> activityMap = {
              'description': item['description'] ?? item['title'] ?? '',
              'date': item['date'] ?? DateTime.now().toIso8601String(),
            };
            await _localRepo.insertActivity(activityMap);
          }
        }
      } catch (e) {
        print("Activity Sync Error: $e");
      }
    }

    // always return local data as truth for ui
    return _localRepo.getActivities();
  }

  @override
  Future<bool> insertActivity(Map<String, dynamic> activity) async {
    final userId = await _prefsManager.getUserId();
    final token = await _prefsManager.getAuthToken();

    // build payload matching backend schema
    final payload = {
      'description': activity['description'] ?? activity['title'] ?? '',
      'date': activity['date'] is DateTime
          ? (activity['date'] as DateTime).toIso8601String()
          : activity['date'],
      'agency_id': userId,
    };

    // save locally first for instant ui feedback
    bool localSuccess = await _localRepo.insertActivity(activity);

    // push to server if online
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/analytics/activities'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode != 201 && response.statusCode != 200) {
          print(
            "Cloud Activity Insert Failed: ${response.statusCode} ${response.body}",
          );
        }
      } catch (e) {
        print("Cloud Activity Network Error: $e");
      }
    }

    return localSuccess;
  }
}
