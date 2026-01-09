/// API Configuration
/// Location: lib/core/config/api_config.dart
class ApiConfig {
  // Change this based on where you're testing:

  // For Android Emulator:
  static const String baseUrl = 'http://10.115.136.178:5000';

  // For iOS Simulator:
  // static const String baseUrl = 'http://127.0.0.1:5000';

  // For Real Device (replace with your computer's IP):
  // static const String baseUrl = 'http://192.168.1.100:5000';

  // Auth endpoints
  static const String authBase = '$baseUrl/auth';
  static const String loginUrl = '$authBase/login';
  static const String signupUrl = '$authBase/signup';
  static const String logoutUrl = '$authBase/logout';
  static const String currentUserUrl = '$authBase/me';
  static const String verifyTokenUrl = '$authBase/verify-token';
  static const String updateProfileUrl = '$authBase/update-profile';
  static const String changePasswordUrl = '$authBase/change-password';
  static const String clientsUrl = '$baseUrl/clients'; // Add the trailing slash
}
