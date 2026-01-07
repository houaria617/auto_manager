import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_manager/core/config/api_config.dart';
import 'package:auto_manager/core/services/connectivity_service.dart';
import 'package:auto_manager/databases/repo/auth/auth_abstract_repo.dart';
import 'package:auto_manager/databases/repo/auth/auth_db_repo.dart';
import 'package:auto_manager/features/auth/data/models/user_model.dart';
import 'package:auto_manager/features/auth/data/models/shared_prefs_manager.dart';

/// Hybrid implementation of authentication repository
/// Tries backend first, falls back to local SharedPreferences
/// Location: lib/databases/repo/auth/auth_hybrid_repo.dart
class AuthHybridRepo implements AuthAbstractRepo {
  final String baseUrl = ApiConfig.baseUrl;
  final AuthDbRepo _localRepo = AuthDbRepo();
  final SharedPrefsManager _prefsManager = SharedPrefsManager();

  /// Change user password/////////////////////////////////////////////////////////////////////////
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // Try online first
    if (await ConnectivityService.isOnline()) {
      try {
        print('🌐 Attempting to change password online...');

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
          print('✅ Password changed successfully');
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
        print('❌ Online password change error: $e');
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    }

    // Offline mode - cannot change password
    return {
      'success': false,
      'message':
          'No internet connection. Please connect to the internet to change your password.',
    };
  }

  /// Update user profile (name and phone)/////////////////////////////////////////////////////////////////////////
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
  }) async {
    // Try online update first
    if (await ConnectivityService.isOnline()) {
      try {
        print('🌐 Attempting online profile update...');

        final token = await _prefsManager.getAuthToken();

        if (token == null) {
          return {'success': false, 'message': 'No authentication token found'};
        }

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

          // Extract updated user data
          final userData = data['user'] as Map<String, dynamic>;

          // Create user model from backend response
          final user = UserModel.fromBackendJson(userData);

          // Update SharedPreferences
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('✅ Online profile update successful');
          return {'success': true, 'message': data['message'], 'user': user};
        } else {
          print('❌ Backend update failed: ${response.body}');
          return {'success': false, 'message': 'Update failed'};
        }
      } catch (e) {
        print('❌ Online update error: $e');
        return {'success': false, 'message': 'Network error: ${e.toString()}'};
      }
    }

    // Offline: Can't update on backend, but can update local data
    print('📱 Offline - cannot update profile on server');
    return {
      'success': false,
      'message': 'No internet connection. Please try again when online.',
    };
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  @override
  Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    // Try online login first
    if (await ConnectivityService.isOnline()) {
      try {
        print('🌐 Attempting online login...');

        final response = await http.post(
          Uri.parse(ApiConfig.loginUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': username, // Backend uses 'email' not 'username'
            'password': password,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          // Extract token and user data
          final token = data['token'] as String;
          final userData = data['user'] as Map<String, dynamic>;

          // Create user model from backend response
          final user = UserModel.fromBackendJson(userData);

          // Save to SharedPreferences
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('✅ Online login successful');
          return user;
        } else if (response.statusCode == 401) {
          // Invalid credentials - don't fall back to offline
          print('❌ Invalid email or password');
          return null;
        } else {
          // Other errors - fall back to offline if available
          print('❌ Backend login failed: ${response.body}');
          print('📱 Falling back to offline login...');
          return await _localRepo.login(username: username, password: password);
        }
      } catch (e) {
        print('❌ Online login error: $e');
        // Only fall back to offline for network errors
        print('📱 Falling back to offline login...');
        return await _localRepo.login(username: username, password: password);
      }
    }

    // Offline mode - use local login
    print('📱 Using offline login...');
    return await _localRepo.login(username: username, password: password);
  }

  @override
  Future<UserModel?> signup({
    required String username,
    required String password,
    required String companyName,
    required String email,
    required String phone,
  }) async {
    // Try online signup first
    if (await ConnectivityService.isOnline()) {
      try {
        print('🌐 Attempting online signup...');

        final response = await http.post(
          Uri.parse(ApiConfig.signupUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'name': companyName, // Backend uses 'name' for company/agency name
            'phone': phone,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          // Extract token and user data
          final token = data['token'] as String;
          final userData = data['user'] as Map<String, dynamic>;

          // Create user model from backend response
          final user = UserModel.fromBackendJson(userData);

          // Save to SharedPreferences
          await _prefsManager.saveUserData(
            userId: user.id,
            username: user.username,
            token: token,
            fullUser: user,
          );

          print('✅ Online signup successful');
          return user;
        } else {
          print('❌ Backend signup failed: ${response.body}');
        }
      } catch (e) {
        print('❌ Online signup error: $e');
      }
    }

    // Fall back to offline/local signup
    print('📱 Falling back to offline signup...');
    return await _localRepo.signup(
      username: username,
      password: password,
      companyName: companyName,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<void> logout() async {
    // Try to call backend logout if online
    if (await ConnectivityService.isOnline()) {
      try {
        print('🌐 Attempting online logout...');

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
        print('❌ Online logout error: $e');
      }
    }

    // Always clear local data
    print('📱 Clearing local data...');
    await _localRepo.logout();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _localRepo.isLoggedIn();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Try to get full user data first
    final fullUser = await _prefsManager.getFullUserData();
    if (fullUser != null) {
      return fullUser;
    }

    // Fall back to basic user data
    return await _localRepo.getCurrentUser();
  }

  /// Verify token with backend (optional, but useful)
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

  /// Get auth token for API calls
  Future<String?> getAuthToken() async {
    return await _prefsManager.getAuthToken();
  }
}
