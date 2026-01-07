import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'rental_repository.dart';
import 'rental_repository_impl.dart';

class RentalHybridRepo implements AbstractRentalRepo {
  final String baseUrl = 'http://localhost:5000';
  final AbstractRentalRepo _localRepo = RentalDB();
  final SharedPrefsManager _prefs = SharedPrefsManager();

  @override
  Future<List<Map>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefs.getUserId();
        final response = await http.get(
          Uri.parse('$baseUrl/rentals/?agency_id=$userId'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          // Sync to local
          for (var item in data) {
            final map = item as Map<String, dynamic>;
            final local = {
              'client_id': map['client_id'],
              'car_id': map['car_id'],
              'date_from': map['date_from'],
              'date_to': map['date_to'],
              'total_amount': map['total_amount'],
              'payment_state': map['payment_state'] ?? 'unpaid',
              // Backend uses rental_state; map to local 'state'
              'state': map['state'] ?? map['rental_state'] ?? 'ongoing',
            };
            await _localRepo.insertRental(local);
          }
          // Return authoritative local rows (with integer ids)
          return (await _localRepo.getData()).map((e) => e as Map).toList();
        }
      } catch (e) {
        // Fall back to local
      }
    }
    return _localRepo.getData();
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final userId = await _prefs.getUserId();
    final payload = {
      ...rental,
      'agency_id': userId,
      'rental_state': rental['state'] ?? 'ongoing',
    };
    final local = {
      'client_id': rental['client_id'],
      'car_id': rental['car_id'],
      'date_from': rental['date_from'],
      'date_to': rental['date_to'],
      'total_amount': rental['total_amount'],
      'payment_state': rental['payment_state'] ?? 'unpaid',
      'state': rental['state'] ?? 'ongoing',
    };
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/rentals/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(payload),
        );
        if (response.statusCode == 201) {
          await _localRepo.insertRental(local);
          return true;
        }
      } catch (e) {
        // Queue for sync
      }
    }
    await _localRepo.insertRental({...local, 'pending_sync': true});
    return true;
  }

  @override
  Future<bool> deleteRental(int index) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.delete(
          Uri.parse('$baseUrl/rentals/$index'),
        );
        if (response.statusCode == 204) {
          await _localRepo.deleteRental(index);
          return true;
        }
      } catch (e) {}
    }
    // Mark for sync or delete locally
    await _localRepo.deleteRental(index);
    return true;
  }

  @override
  Future<bool> updateRental(int index, Map<String, dynamic> rental) async {
    final data = {...rental, 'agency_id': rental['agency_id'] ?? 1};
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/rentals/$index'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (response.statusCode == 200) {
          await _localRepo.updateRental(index, data);
          return true;
        }
      } catch (e) {}
    }
    await _localRepo.updateRental(index, {...data, 'pending_sync': true});
    return true;
  }
}
