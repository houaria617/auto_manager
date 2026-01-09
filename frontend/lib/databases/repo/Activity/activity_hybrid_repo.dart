// lib/databases/repo/Activity/activity_hybrid_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:auto_manager/databases/dbhelper.dart';
import 'activity_abstract.dart';
import 'activity_db.dart';

class ActivityHybridRepo extends AbstractActivityRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractActivityRepo _localRepo = ActivityDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  @override
  Future<List<Map<String, dynamic>>> getActivities() async {
    // 1. Try to sync with cloud if online
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefsManager.getUserId();
        final token = await _prefsManager.getAuthToken();

        // Ensure we are hitting the correct analytics endpoint
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
          // 2. Replace local SQLite activities with cloud data (avoid duplicates)
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
        // Fall back to local data on failure
      }
    }

    // 3. Always return local data as the single source of truth for the UI
    // This ensures sorting (ORDER BY date DESC) and limits are applied correctly
    return _localRepo.getActivities();
  }

  @override
  Future<bool> insertActivity(Map<String, dynamic> activity) async {
    final userId = await _prefsManager.getUserId();
    final token = await _prefsManager.getAuthToken();

    // Prepare payload to match backend: description + date + agency_id
    final payload = {
      'description': activity['description'] ?? activity['title'] ?? '',
      'date': activity['date'] is DateTime
          ? (activity['date'] as DateTime).toIso8601String()
          : activity['date'],
      'agency_id': userId,
    };

    // 1. Save locally first (immediate UI feedback)
    bool localSuccess = await _localRepo.insertActivity(activity);

    // 2. Try to save to cloud if online
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
