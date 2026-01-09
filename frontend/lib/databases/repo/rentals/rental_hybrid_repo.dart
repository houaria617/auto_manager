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
          final localData = await _localRepo.getData();

          for (var item in data) {
            final remoteId = item['remote_id'];

            // Check if this rental already exists locally by remote_id
            final existingRental = localData.firstWhere(
              (local) => local['remote_id'] == remoteId,
              orElse: () => {},
            );

            if (existingRental.isNotEmpty) {
              // Update existing rental
              await _localRepo.updateRental(existingRental['id'], {
                'client_id': item['client_id'],
                'car_id': item['car_id'],
                'date_from': item['date_from'],
                'date_to': item['date_to'],
                'total_amount': item['total_amount'],
                'payment_state': item['payment_state'],
                'state': item['rental_state'] ?? item['state'],
                'remote_id': remoteId,
                'pending_sync': 0,
              });
            } else {
              // Insert new rental from server
              await _localRepo.insertRental({
                'client_id': item['client_id'],
                'car_id': item['car_id'],
                'date_from': item['date_from'],
                'date_to': item['date_to'],
                'total_amount': item['total_amount'],
                'payment_state': item['payment_state'],
                'state': item['rental_state'] ?? item['state'],
                'remote_id': remoteId,
                'pending_sync': 0,
              });
            }
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
    // 1. Save locally IMMEDIATELY (initially with pending_sync: 1)
    await _localRepo.insertRental({...rental, 'pending_sync': 1});

    // 2. Try to sync immediately if online
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/rentals/'),
          headers: await _getHeaders(),
          body: json.encode({
            'client_id': rental['client_id'],
            'car_id': rental['car_id'],
            'date_from': rental['date_from'],
            'date_to': rental['date_to'],
            'total_amount': rental['total_amount'],
            'payment_state': rental['payment_state'],
            'rental_state': rental['state'], // Backend uses rental_state
          }),
        );

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          final remoteId = data['id'];

          // Update the local record to mark it as synced
          final localData = await _localRepo.getData();
          final localRecord = localData.lastWhere(
            (e) =>
                e['client_id'] == rental['client_id'] &&
                e['car_id'] == rental['car_id'],
            orElse: () => {},
          );

          if (localRecord.isNotEmpty) {
            await _localRepo.updateRental(localRecord['id'], {
              ...rental,
              'pending_sync': 0,
              'remote_id': remoteId,
            });
          }
          print("RentalHybridRepo: New rental synced immediately to Firebase");
        }
      } catch (e) {
        print(
          "RentalHybridRepo: Immediate sync failed, will retry in background: $e",
        );
      }
    }

    // 3. Trigger background sync as fallback
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask("sync-now", "sync-task");
    }

    return true;
  }

  @override
  Future<bool> updateRental(int localId, Map<String, dynamic> rental) async {
    // 1. Update locally immediately (with pending_sync: 1)
    await _localRepo.updateRental(localId, {...rental, 'pending_sync': 1});

    // 2. Try to sync immediately if online
    if (await ConnectivityService.isOnline()) {
      try {
        final localData = await _localRepo.getData();
        final record = localData.firstWhere(
          (e) => e['id'] == localId,
          orElse: () => {},
        );

        final String? remoteId = record['remote_id'];

        if (remoteId != null) {
          print(
            "RentalHybridRepo: Syncing update for rental $remoteId with state=${rental['state']}, payment_state=${rental['payment_state']}",
          );

          final response = await http.put(
            Uri.parse('${ApiConfig.baseUrl}/rentals/$remoteId'),
            headers: await _getHeaders(),
            body: json.encode({
              'payment_state':
                  rental['payment_state'] ??
                  record['payment_state'] ??
                  'unpaid',
              'rental_state': rental['state'],
            }),
          );

          print(
            "RentalHybridRepo: Update response status: ${response.statusCode}",
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Mark as synced locally
            await _localRepo.updateRental(localId, {
              ...rental,
              'pending_sync': 0,
              'remote_id': remoteId,
            });
            print(
              "RentalHybridRepo: Rental update synced immediately to Firebase",
            );
            return true;
          } else {
            print(
              "RentalHybridRepo: Failed to sync, status: ${response.statusCode}, body: ${response.body}",
            );
          }
        } else {
          print(
            "RentalHybridRepo: No remote_id found, will sync in background",
          );
        }
      } catch (e) {
        print(
          "RentalHybridRepo: Immediate sync failed, will retry in background: $e",
        );
      }
    } else {
      print("RentalHybridRepo: Offline, rental will sync in background");
    }

    // 3. Trigger background sync as fallback
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
