import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/databases/repo/auth/auth_abstract_repo.dart';
import 'package:auto_manager/databases/repo/auth/auth_db_repo.dart';
import 'package:auto_manager/features/auth/data/models/user_model.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';

// hybrid auth repo - tries api first, falls back to local
class AuthHybridRepo implements AuthAbstractRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthDbRepo _localRepo = AuthDbRepo();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  // updates password on the server
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // can only change password when online
    if (await ConnectivityService.isOnline()) {
      try {
        print('\ud83c\udf10 Attempting to change password online...');

        final token = await _prefsManager.getAuthToken();

        if (token == null) {
          return {'success': false, 'message': 'No authentication token found'};
        }

        final response = await http.put(
          Uri.parse(ApiConfig.changePasswordUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'old_password': oldPassword,
            'new_password': newPassword,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          print('\u2705 Password changed successfully');
          return {
            'success': true,
            'message': data['message'] ?? 'Password changed successfully',
          };
        } else if (response.statusCode == 401) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': data['error'] ?? 'Old password is incorrect',
          };
        } else {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return {
            'success': false,
            'message': data['error'] ?? 'Failed to change password',
          };
        }
      } catch (e) {
        print('\u274c Online password change error: $e');
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    }

    // password changes require internet
    return {
      'success': false,
      'message':
          'No internet connection. Please connect to the internet to change your password.',
    };
  }

  // updates user profile info on the server
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    if (await ConnectivityService.isOnline()) {
      try {
        print('\ud83c\udf10 Attempting online profile update...');

        final token = await _prefsManager.getAuthToken();

        if (token == null) {
          return {'success': false, 'message': 'No authentication token found'};
        }

        // build payload with only provided fields
        final body = <String, dynamic>{};
        if (name != null) body['name'] = name;
        if (phone != null) body['phone'] = phone;

        final response = await http.put(
          Uri.parse(ApiConfig.updateProfileUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final userData = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromBackendJson(userData);

          // update local storage with new data
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('\u2705 Online profile update successful');
          return {'success': true, 'message': data['message'], 'user': user};
        } else {
          print('\u274c Backend update failed: ${response.body}');
          return {'success': false, 'message': 'Update failed'};
        }
      } catch (e) {
        print('\u274c Online update error: $e');
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    }

    // profile updates require internet
    print('\ud83d\udcf1 Offline - cannot update profile on server');
    return {
      'success': false,
      'message': 'No internet connection. Please try again when online.',
    };
  }

  // authenticates user with the backend
  @override
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    // try api login first
    if (await ConnectivityService.isOnline()) {
      try {
        print('\ud83c\udf10 Attempting online login...');

        final response = await http.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': username, 'password': password}),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final token = data['token'] as String;
          final userData = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromBackendJson(userData);

          // save session locally
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('\u2705 Online login successful');
          return user;
        } else if (response.statusCode == 401) {
          // wrong credentials, dont fall back
          print('\u274c Invalid email or password');
          return null;
        } else {
          // server error, try offline
          print('\u274c Backend login failed: ${response.body}');
          print('\ud83d\udcf1 Falling back to offline login...');
          return await _localRepo.login(username: username, password: password);
        }
      } catch (e) {
        // network error, try offline
        print('\u274c Online login error: $e');
        print('\ud83d\udcf1 Falling back to offline login...');
        return await _localRepo.login(username: username, password: password);
      }
    }

    // no internet, use local login
    print('\ud83d\udcf1 Using offline login...');
    return await _localRepo.login(username: username, password: password);
  }

  // registers new user on the backend
  @override
  Future<UserModel?> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  }) async {
    if (await ConnectivityService.isOnline()) {
      try {
        print('\ud83c\udf10 Attempting online signup...');

        final response = await http.post(
          Uri.parse(ApiConfig.signupUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'name': companyName,
            'phone': phone,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final token = data['token'] as String;
          final userData = data['user'] as Map<String, dynamic>;
          final user = UserModel.fromBackendJson(userData);

          // save new user session
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('\u2705 Online signup successful');
          return user;
        } else {
          print('\u274c Backend signup failed: ${response.body}');
        }
      } catch (e) {
        print('\u274c Online signup error: $e');
      }
    }

    // fall back to local signup
    print('\ud83d\udcf1 Falling back to offline signup...');
    return await _localRepo.signup(
      username: username,
      password: password,
      companyName: companyName,
      email: email,
      phone: phone,
    );
  }

  // logs out user locally and on server
  @override
  Future<void> logout() async {
    // notify server if online
    if (await ConnectivityService.isOnline()) {
      try {
        print('\ud83c\udf10 Attempting online logout...');

        final token = await _prefsManager.getAuthToken();

        if (token != null) {
          final response = await http.post(
            Uri.parse(ApiConfig.logoutUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          print('Logout response: ${response.statusCode}');
        }
      } catch (e) {
        print('\u274c Online logout error: $e');
      }
    }

    // always clear local data
    print('\ud83d\udcf1 Clearing local data...');
    await _localRepo.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localRepo.isLoggedIn();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // try full user data first
    final fullUser = await _prefsManager.getFullUserData();
    if (fullUser != null) {
      return fullUser;
    }
    // fall back to basic data
    return await _localRepo.getCurrentUser();
  }

  // checks if stored token is still valid
  Future<bool> verifyToken() async {
    if (!await ConnectivityService.isOnline()) {
      return false;
    }

    try {
      final token = await _prefsManager.getAuthToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse(ApiConfig.verifyTokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['valid'] == true;
      }

      return false;
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }

  // exposes the auth token for other api calls
  Future<String?> getAuthToken() async {
    return await _prefsManager.getAuthToken();
  }
}
