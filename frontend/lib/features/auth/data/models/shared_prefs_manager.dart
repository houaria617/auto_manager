import 'package:shared_preferences/shared_preferences.dart';

/// Manages all SharedPreferences operations for user authentication
/// Stores: userId, username
/// Location: lib/data/databases/auth/shared_prefs_manager.dart
class SharedPrefsManager {
  // Keys for storing data
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';

  /// Save user data after login/signup
  /// Returns true if successful
  Future<bool> saveUserData({
    required int userId,
    required String username,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserId, userId);
      await prefs.setString(_keyUsername, username);
      return true;
    } catch (e) {
      print('Error saving user data: $e');
      return false;
    }
  }

  /// Get stored user ID
  /// Returns null if not found
  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  /// Get stored username
  /// Returns null if not found
  Future<String?> getUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUsername);
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  /// Check if user is logged in
  /// Returns true if userId exists in SharedPreferences
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_keyUserId);
      return userId != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Clear all user data (logout)
  /// Returns true if successful
  Future<bool> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUsername);
      return true;
    } catch (e) {
      print('Error clearing user data: $e');
      return false;
    }
  }
}
