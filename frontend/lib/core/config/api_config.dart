// api endpoints for the flask backend
class ApiConfig {
  // switch this depending on where you're testing from
  // android emulator uses 10.0.2.2 to reach host machine
  static const String baseUrl = 'http://10.175.6.168:5000';

  // ios simulator can use localhost directly
  // static const String baseUrl = 'http://127.0.0.1:5000';

  // for real device use your computer's local ip
  // static const String baseUrl = 'http://192.168.1.100:5000';

  // auth routes
  static const String authBase = '$baseUrl/auth';
  static const String loginUrl = '$authBase/login';
  static const String signupUrl = '$authBase/signup';
  static const String logoutUrl = '$authBase/logout';
  static const String currentUserUrl = '$authBase/me';
  static const String verifyTokenUrl = '$authBase/verify-token';
  static const String updateProfileUrl = '$authBase/update-profile';
  static const String changePasswordUrl = '$authBase/change-password';

  // resource endpoints
  static const String clientsUrl = '$baseUrl/clients';
}
