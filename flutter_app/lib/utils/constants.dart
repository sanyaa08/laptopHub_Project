class AppConstants {
  // ─── API ──────────────────────────────────────────────
  // Change this to your actual server IP when running on device
  static const String baseUrl = 'http://10.2.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  // static const String baseUrl = 'http://192.168.x.x:3000/api'; // Physical device

  // ─── Storage Keys ─────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // ─── Timeouts ─────────────────────────────────────────
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
