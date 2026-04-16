import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Generic Getters/Setters
  static String? getString(String key) => _prefs.getString(key);
  static Future<void> setString(String key, String value) => _prefs.setString(key, value);

  static bool getBool(String key, {bool defaultValue = false}) => _prefs.getBool(key) ?? defaultValue;
  static Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);
  static Future<void> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);
  static Future<void> clear() => _prefs.clear();
  static bool containsKey(String key) => _prefs.containsKey(key);

  // Specific Keys
  static const String keyUser = 'user_data';
  static const String keyAuthToken = 'auth_token';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyDarkMode = 'dark_mode';
  static const String keyLanguage = 'language';
  static const String keyBiometricEnabled = 'biometric_enabled';
  static const String keyRememberMe = 'remember_me';
}
