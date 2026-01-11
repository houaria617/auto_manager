import 'package:connectivity_plus/connectivity_plus.dart';

// simple wrapper to check internet connectivity
class ConnectivityService {
  // returns true if device has any network connection
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
