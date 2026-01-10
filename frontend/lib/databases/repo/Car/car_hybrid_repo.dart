// lib/databases/repo/Car/car_hybrid_repo.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';
import 'car_abstract.dart';
import 'car_db.dart';

class CarHybridRepo extends AbstractCarRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AbstractCarRepo _localRepo = CarDB();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  // --- Helper for Headers ---
  Future<Map<String, String>> _getHeaders() async {
    final token = await _prefsManager.getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final headers = await _getHeaders();
        final response = await http
            .get(Uri.parse('$baseUrl/vehicles/'), headers: headers)
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);

          // Get existing local cars
          final existingCars = await _localRepo.getAllCars();
          final Map<String, int> byRemoteId = {};
          final Map<String, int> byPlate = {};

          for (var row in existingCars) {
            final id = row['id'] as int;
            if (row['remote_id'] != null) {
              byRemoteId[row['remote_id'] as String] = id;
            }
            if (row['plate'] != null) {
              byPlate[row['plate'] as String] = id;
            }
          }

          // Sync cloud data into local SQLite
          for (var item in data) {
            final remoteId = item['id'];
            final plate = item['plate'];

            // Normalize data to match your SQLite schema
            final Map<String, dynamic> carMap = {
              'remote_id': remoteId,
              'pending_sync': 0,
              'name': item['name'] ?? '',
              'plate': plate ?? '',
              'price': item['rent_price'] ?? item['price'] ?? 0.0,
              'state': item['state'] ?? 'available',
              'maintenance':
                  item['maintenance_date'] ?? item['maintenance'] ?? '',
              'return_from_maintenance': item['return_from_maintenance'] ?? '',
            };

            int? targetId;
            if (remoteId != null && byRemoteId.containsKey(remoteId)) {
              targetId = byRemoteId[remoteId];
            } else if (plate != null && byPlate.containsKey(plate)) {
              targetId = byPlate[plate];
            }

            if (targetId != null) {
              await _localRepo.updateCar(targetId, carMap);
            } else {
              await _localRepo.insertCar(carMap);
            }
          }
        }
      } catch (e) {
        print("Car Sync Error: $e");
      }
    }
    return _localRepo.getData();
  }

  @override
  Future<int> insertCar(Map<String, dynamic> car) async {
    final userId = await _prefsManager.getUserId();
    final headers = await _getHeaders();

    // Prepare payload for server
    final payload = {
      'agency_id': userId,
      'name': car['name'],
      'plate': car['plate'],
      'rent_price': car['price'],
      'state': car['state'],
      'maintenance_date': car['maintenance'],
      'return_from_maintenance': car['return_from_maintenance'],
    };

    // Prepare local car data
    final localCar = {
      'name': car['name'],
      'plate': car['plate'],
      'price': car['price'],
      'state': car['state'],
      'maintenance': car['maintenance'],
      'return_from_maintenance': car['return_from_maintenance'],
      'pending_sync': 1,
    };

    if (await ConnectivityService.isOnline()) {
      try {
        print("CarHybridRepo: Sending POST to $baseUrl/vehicles/");
        final response = await http
            .post(
              Uri.parse('$baseUrl/vehicles/'),
              headers: headers,
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 10));

        print("CarHybridRepo: Response status: ${response.statusCode}");

        if (response.statusCode == 201 || response.statusCode == 200) {
          final respData = json.decode(response.body);
          localCar['remote_id'] = respData['id'];
          localCar['pending_sync'] = 0;
          print(
            "CarHybridRepo: Car saved to Firebase with id: ${respData['id']}",
          );
        }
      } catch (e) {
        print("Cloud Car Insert Error: $e");
      }
    }

    return await _localRepo.insertCar(localCar);
  }

  @override
  Future<Map<String, dynamic>?> getCar(int id) async {
    // For specific items, local is usually faster and more reliable
    return _localRepo.getCar(id);
  }

  @override
  Future<void> updateCar(int id, Map<String, dynamic> car) async {
    final headers = await _getHeaders();

    // Get the existing record to find remote_id
    final existing = await _localRepo.getCar(id);
    final remoteId = existing?['remote_id'];

    // Update locally
    await _localRepo.updateCar(id, car);

    if (await ConnectivityService.isOnline() && remoteId != null) {
      try {
        final payload = {
          'name': car['name'],
          'plate': car['plate'],
          'rent_price': car['price'],
          'state': car['state'],
          'maintenance_date': car['maintenance'],
          'return_from_maintenance': car['return_from_maintenance'],
        };

        await http
            .put(
              Uri.parse('$baseUrl/vehicles/$remoteId'),
              headers: headers,
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        print("Cloud Car Update Error: $e");
      }
    }
  }

  @override
  Future<void> updateCarStatus(int carId, String status) async {
    final headers = await _getHeaders();

    // Get the existing record to find remote_id
    final existing = await _localRepo.getCar(carId);
    final remoteId = existing?['remote_id'];

    await _localRepo.updateCarStatus(carId, status);

    if (await ConnectivityService.isOnline() && remoteId != null) {
      try {
        await http
            .put(
              Uri.parse('$baseUrl/vehicles/$remoteId'),
              headers: headers,
              body: json.encode({'state': status}),
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        print("Cloud Status Update Error: $e");
      }
    }
  }

  @override
  Future<void> deleteCar(int id) async {
    final headers = await _getHeaders();

    // Get the existing record to find remote_id
    final existing = await _localRepo.getCar(id);
    final remoteId = existing?['remote_id'];

    await _localRepo.deleteCar(id);

    if (await ConnectivityService.isOnline() && remoteId != null) {
      try {
        await http
            .delete(Uri.parse('$baseUrl/vehicles/$remoteId'), headers: headers)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        print("Cloud Car Delete Error: $e");
      }
    }
  }

  @override
  Future<int> countAvailableCars() async {
    return _localRepo.countAvailableCars();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCars() async {
    return getData();
  }

  @override
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(
    String dateIsoString,
  ) async {
    return _localRepo.getCarsMaintenanceOn(dateIsoString);
  }
}
