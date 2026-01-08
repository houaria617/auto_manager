import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'rental_repository.dart';
import 'rental_repository_impl.dart';

class RentalHybridRepo implements AbstractRentalRepo {
  final AbstractRentalRepo _localRepo = RentalDB();
  final SharedPrefsManager _prefs = SharedPrefsManager();

  // Helper to get headers with JWT (matching your AuthHybridRepo)
  Future<Map<String, String>> _getHeaders() async {
    final token = await _prefs.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Map>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/rentals/'),
          headers: await _getHeaders(),
        );
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          for (var item in data) {
            await _localRepo.insertRental({
              ...item,
              'remote_id': item['remote_id'], // Map the Firestore ID
              'state': item['rental_state'] ?? item['state'],
            });
          }
        }
      } catch (e) {
        print("Sync Error: $e");
      }
    }
    return _localRepo.getData();
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    // 1. Save locally IMMEDIATELY (with pending_sync: 1)
    await _localRepo.insertRental({...rental, 'pending_sync': 1});

    // 2. Trigger sync in background
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask("sync-now", "sync-task");
    }

    return true; // <--- Add this to satisfy the Abstract class
  }

  @override
  Future<bool> updateRental(int localId, Map<String, dynamic> rental) async {
    // 1. Update locally immediately
    await _localRepo.updateRental(localId, {
      ...rental,
      'pending_sync': 1, // Mark for background job
    });

    // 2. Trigger background sync
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask("sync-task-update", "sync-task");
    }

    return true;
  }

  @override
  Future<bool> deleteRental(int localId) async {
    final localData = await _localRepo.getData();
    final record = localData.firstWhere(
      (e) => e['id'] == localId,
      orElse: () => {},
    );
    final String? remoteId = record['remote_id'];

    if (await ConnectivityService.isOnline() && remoteId != null) {
      try {
        await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/rentals/$remoteId'),
          headers: await _getHeaders(),
        );
      } catch (e) {}
    }
    return await _localRepo.deleteRental(localId);
  }
}
