// handles storing and retrieving auth data from local storage

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';

class SharedPrefsManager {
  // keys for stored values
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserData = 'user_data';

  // saves user data after successful login or signup
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

    if (token != null) {
      await prefs.setString(_keyAuthToken, token);
    }

    if (fullUser != null) {
      await prefs.setString(_keyUserData, jsonEncode(fullUser.toJson()));
    }
  }

  // retrieves stored jwt token
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  // retrieves user id as int or string depending on source
  Future<dynamic> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final idString = prefs.getString(_keyUserId);
    if (idString == null) return null;

    return int.tryParse(idString) ?? idString;
  }

  // retrieves stored username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // retrieves full user object if stored
  Future<UserModel?> getFullUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_keyUserData);

    if (userDataString == null) return null;

    try {
      final json = jsonDecode(userDataString) as Map<String, dynamic>;
      return UserModel.fromLocalJson(json);
    } catch (e) {
      print('error parsing user data: $e');
      return null;
    }
  }

  // checks if user has an active session
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // clears all stored user data on logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyAuthToken);
    await prefs.remove(_keyUserData);
    await prefs.setBool(_keyIsLoggedIn, false);
  }
}
