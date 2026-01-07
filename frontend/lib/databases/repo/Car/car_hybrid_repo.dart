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

  @override
  Future<List<Map<String, dynamic>>> getData() async {
    if (await ConnectivityService.isOnline()) {
      try {
        final userId = await _prefsManager.getUserId();
        final response = await http
            .get(Uri.parse('$baseUrl/vehicles/?agency_id=$userId'))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final List data = json.decode(response.body);
          // Sync to local
          for (var item in data) {
            final car = {
              // Note: local DB doesn't have agency_id yet, but let's keep it safe
              'name': item['name'],
              'plate': item['plate'],
              'price': item['rent_price'] ?? item['price'] ?? 0.0,
              'state': item['state'],
              'maintenance': item['maintenance_date'] ?? item['maintenance'],
              'return_from_maintenance': item['return_from_maintenance'],
            };
            await _localRepo.insertCar(car);
          }
          return data.cast<Map<String, dynamic>>();
        }
      } catch (e) {
        // Fall back to local
      }
    }
    return _localRepo.getData();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCars() async {
    return await getData();
  }

  @override
  Future<Map<String, dynamic>?> getCar(dynamic id) async {
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/vehicles/$id'))
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          return json.decode(response.body) as Map<String, dynamic>;
        }
      } catch (e) {}
    }
    return _localRepo.getCar(id);
  }

  @override
  Future<int> insertCar(Map<String, dynamic> car) async {
    final userId = await _prefsManager.getUserId();
    final data = {...car, 'agency_id': car['agency_id'] ?? userId ?? 1};
    if (await ConnectivityService.isOnline()) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/vehicles/'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(data),
            )
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 201) {
          final result = json.decode(response.body);
          // Map to local format before saving
          final localData = {
            'name': data['name'],
            'plate': data['plate'],
            'price': data['rent_price'] ?? data['price'],
            'state': data['state'],
            'maintenance': data['maintenance_date'] ?? data['maintenance'],
            'return_from_maintenance': data['return_from_maintenance'],
          };
          await _localRepo.insertCar(localData);
          return 1; // Success
        }
      } catch (e) {}
    }
    return await _localRepo.insertCar(car);
  }

  @override
  Future<void> updateCar(dynamic id, Map<String, dynamic> car) async {
    if (await ConnectivityService.isOnline()) {
      try {
        await http
            .put(
              Uri.parse('$baseUrl/vehicles/$id'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(car),
            )
            .timeout(const Duration(seconds: 5));
      } catch (e) {}
    }
    await _localRepo.updateCar(id, car);
  }

  @override
  Future<void> deleteCar(dynamic id) async {
    if (await ConnectivityService.isOnline()) {
      try {
        await http
            .delete(Uri.parse('$baseUrl/vehicles/$id'))
            .timeout(const Duration(seconds: 5));
      } catch (e) {}
    }
    await _localRepo.deleteCar(id);
  }

  @override
  Future<int> countAvailableCars() async {
    // For simplicity, we get stats from local for now,
    // or we could add an analytics endpoint in backend.
    return await _localRepo.countAvailableCars();
  }

  @override
  Future<void> updateCarStatus(dynamic carId, String status) async {
    if (await ConnectivityService.isOnline()) {
      try {
        await http.put(
          Uri.parse('$baseUrl/vehicles/$carId'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'state': status}),
        );
      } catch (e) {}
    }
    await _localRepo.updateCarStatus(carId, status);
  }

  @override
  Future<List<Map<String, dynamic>>> getCarsMaintenanceOn(
    String dateIsoString,
  ) async {
    return _localRepo.getCarsMaintenanceOn(dateIsoString);
  }
}
