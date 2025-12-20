import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiveStorage {
  static late Box _authBox;
  static late Box _userBox;
  static late Box _settingsBox;
  static late Box _cacheBox;
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> init() async {
    // Initialize Hive with Flutter
    await Hive.initFlutter();

    // Register adapters here if you create custom Hive models
    // Hive.registerAdapter(YourModelAdapter());

    // Open boxes
    _authBox = await Hive.openBox('auth');
    _userBox = await Hive.openBox('user');
    _settingsBox = await Hive.openBox('settings');
    _cacheBox = await Hive.openBox('cache');
  }

  // ==================== Auth Token Management ====================

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _authBox.put(
      'token_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    await _authBox.put('is_logged_in', true);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: 'refresh_token', value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: 'refresh_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAuth() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'refresh_token');
    await _authBox.clear();
  }

  // ==================== User Data ====================

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _userBox.put('user_data', userData);
    await _userBox.put('user_role', userData['role']);
    await _userBox.put('user_email', userData['email']);
  }

  static Map<String, dynamic>? getUserData() {
    final data = _userBox.get('user_data');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static String? getUserRole() {
    return _userBox.get('user_role');
  }

  static String? getUserEmail() {
    return _userBox.get('user_email');
  }

  static Future<void> clearUserData() async {
    await _userBox.clear();
  }

  // ==================== Profile Data ====================

  static Future<void> saveProfileData(Map<String, dynamic> profileData) async {
    await _userBox.put('profile_data', profileData);
  }

  static Map<String, dynamic>? getProfileData() {
    final data = _userBox.get('profile_data');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  // ==================== Settings ====================

  static Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put('theme_mode', mode);
  }

  static String getThemeMode() {
    return _settingsBox.get('theme_mode', defaultValue: 'dark');
  }

  static Future<void> saveLanguage(String language) async {
    await _settingsBox.put('language', language);
  }

  static String getLanguage() {
    return _settingsBox.get('language', defaultValue: 'en');
  }

  // ==================== Cache ====================

  static Future<void> cacheCategories(
    List<Map<String, dynamic>> categories,
  ) async {
    await _cacheBox.put('categories', categories);
    await _cacheBox.put(
      'categories_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<Map<String, dynamic>>? getCachedCategories() {
    final timestamp = _cacheBox.get('categories_timestamp');
    if (timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Cache valid for 24 hours
      if (now.difference(cacheTime).inHours < 24) {
        final data = _cacheBox.get('categories');
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    }
    return null;
  }

  static Future<void> cacheRecentJobs(List<Map<String, dynamic>> jobs) async {
    await _cacheBox.put('recent_jobs', jobs);
    await _cacheBox.put(
      'jobs_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static List<Map<String, dynamic>>? getCachedRecentJobs() {
    final timestamp = _cacheBox.get('jobs_timestamp');
    if (timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Cache valid for 1 hour
      if (now.difference(cacheTime).inMinutes < 60) {
        final data = _cacheBox.get('recent_jobs');
        if (data is List) {
          return data.cast<Map<String, dynamic>>();
        }
      }
    }
    return null;
  }

  // ==================== Clear All Data ====================

  static Future<void> clearAll() async {
    await clearAuth();
    await clearUserData();
    await _settingsBox.clear();
    await _cacheBox.clear();
  }

  static Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // ==================== Debug ====================

  static void printAllData() {
    print('=== Auth Box ===');
    print(_authBox.toMap());
    print('=== User Box ===');
    print(_userBox.toMap());
    print('=== Settings Box ===');
    print(_settingsBox.toMap());
  }
}
