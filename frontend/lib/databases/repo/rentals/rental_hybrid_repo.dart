import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'rental_repository.dart';
import 'rental_repository_impl.dart';

class RentalHybridRepo implements AbstractRentalRepo {
  final String baseUrl = ApiConfig.baseUrl; // Updated to use centralized config
  final AbstractRentalRepo _localRepo = RentalDB();

  @override
  Future<List<Map>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/rentals/?agency_id=1'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          // Sync to local
          for (var item in data) {
            final filtered = {
              'client_id': item['client_id'],
              'car_id': item['car_id'],
              'date_from': item['date_from'],
              'date_to': item['date_to'],
              'total_amount': item['total_amount'],
              'payment_state': item['payment_state'] ?? 'Unpaid',
              'state': item['state'] ?? 'active',
            };
            await _localRepo.insertRental(filtered);
          }
          return data.map((e) => e as Map).toList();
        }
      } catch (e) {
        // Fall back to local
      }
    }
    return _localRepo.getData();
  }

  @override
  Future<bool> insertRental(Map<String, dynamic> rental) async {
    final data = {
      ...rental,
      'agency_id': 1,
      'rental_state': rental['state'] ?? 'active',
    };
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/rentals/'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );
        if (response.statusCode == 201) {
          await _localRepo.insertRental(data);
          return true;
        }
      } catch (e) {
        // Queue for sync
      }
    }
    await _localRepo.insertRental({...data, 'pending_sync': true});
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
