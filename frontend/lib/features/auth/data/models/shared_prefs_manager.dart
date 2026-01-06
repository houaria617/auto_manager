import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

/// Manages authentication data in SharedPreferences
/// Location: lib/features/auth/data/models/shared_prefs_manager.dart
class SharedPrefsManager {
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token'; // NEW: for JWT token
  static const String _keyUserData = 'user_data'; // NEW: for full user object

  /// Save user data after login/signup
  Future<void> saveUserData({
    required dynamic userId,
    required String username,
    String? token,
    UserModel? fullUser,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyUserId, userId.toString());
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLoggedIn, true);
    
    // Save token if provided (from backend)
    if (token != null) {
      await prefs.setString(_keyAuthToken, token);
    }
    
    // Save full user object if provided
    if (fullUser != null) {
      await prefs.setString(_keyUserData, jsonEncode(fullUser.toJson()));
    }
  }

  /// Get stored auth token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  /// Get user ID
  Future<dynamic> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString(_keyUserId);
    if (idString == null) return null;
    
    // Try to parse as int first (local), fallback to string (backend)
    return int.tryParse(idString) ?? idString;
  }

  /// Get username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Get full user data
  Future<UserModel?> getFullUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);
    
    if (userDataString == null) return null;
    
    try {
      final json = jsonDecode(userDataString) as Map<String, dynamic>;
      return UserModel.fromLocalJson(json);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Clear all user data (logout)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}