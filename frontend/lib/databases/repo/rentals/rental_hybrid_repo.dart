// hybrid rental repo that syncs between local sqlite and remote api

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'package:workmanager/workmanager.dart';
import 'package:auto_manager/databases/repo/Car/car_db.dart';
import 'rental_repository.dart';
import 'rental_repository_impl.dart';

class RentalHybridRepo implements AbstractRentalRepo {
  final AbstractRentalRepo _localRepo = RentalDB();
  final SharedPrefsManager _prefs = SharedPrefsManager();

  // builds auth headers with jwt token for api calls
  Future<Map<String, String>> _getHeaders() async {
    final token = await _prefs.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // fetches rentals from server when online and merges with local data
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

          // sync each remote rental to local database
          for (var item in data) {
            final remoteId = item['remote_id'];

            final existingRental = localData.firstWhere(
              (local) => local['remote_id'] == remoteId,
              orElse: () => {},
            );

            if (existingRental.isNotEmpty) {
              // update existing local record with server data
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
              // insert new rental from server
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
        print("sync error: $e");
      }
    }
    return _localRepo.getData();
  }

  // saves rental locally first then tries immediate sync if online
  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    // save to local db immediately with pending sync flag
    await _localRepo.insertRental({...rental, 'pending_sync': 1});

    // attempt immediate sync when we have connectivity
    if (await ConnectivityService.isOnline()) {
      try {
        // get car remote id if available for proper server reference
        String? carRemoteId;
        try {
          final car = await CarDB().getCar(rental['car_id']);
          if (car != null && car['remote_id'] is String) {
            carRemoteId = car['remote_id'] as String;
          }
        } catch (_) {}

        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/rentals/'),
          headers: await _getHeaders(),
          body: json.encode({
            'client_id': rental['client_id'],
            'car_id': carRemoteId ?? rental['car_id'],
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

          // find local record and update with remote id to mark as synced
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
          print("rental synced immediately to firebase");
        }
      } catch (e) {
        print("immediate sync failed, will retry in background: $e");
      }
    }

    // schedule background sync as fallback for failed or offline scenarios
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask("sync-now", "sync-task");
    }

    return true;
  }

  // updates rental locally then attempts to push changes to server
  @override
  Future<bool> updateRental(int localId, Map<String, dynamic> rental) async {
    // save update locally first with pending sync flag
    await _localRepo.updateRental(localId, {...rental, 'pending_sync': 1});

    // try to sync the update immediately if online
    if (await ConnectivityService.isOnline()) {
      try {
        final localData = await _localRepo.getData();
        final record = localData.firstWhere(
          (e) => e['id'] == localId,
          orElse: () => {},
        );

        final String? remoteId = record['remote_id'];

        if (remoteId != null) {
          print("syncing update for rental $remoteId");

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

          print("update response status: ${response.statusCode}");

          if (response.statusCode == 200 || response.statusCode == 201) {
            // mark as synced in local db
            await _localRepo.updateRental(localId, {
              ...rental,
              'pending_sync': 0,
              'remote_id': remoteId,
            });
            print("rental update synced to firebase");
            return true;
          } else {
            print("failed to sync, status: ${response.statusCode}");
          }
        } else {
          print("no remote_id found, will sync in background");
        }
      } catch (e) {
        print("immediate sync failed, will retry in background: $e");
      }
    } else {
      print("offline, rental will sync in background");
    }

    // schedule background sync as fallback
    if (Platform.isAndroid || Platform.isIOS) {
      Workmanager().registerOneOffTask("sync-task-update", "sync-task");
    }

    return true;
  }

  // deletes locally and attempts remote deletion if online
  @override
  Future<bool> deleteRental(int localId) async {
    final localData = await _localRepo.getData();
    final record = localData.firstWhere(
      (e) => e['id'] == localId,
      orElse: () => {},
    );
    final String? remoteId = record['remote_id'];

    // try to delete from server if we have connectivity and remote id
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
