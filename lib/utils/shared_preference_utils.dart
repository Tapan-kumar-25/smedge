import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceUtils {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  static bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  static Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  static int getInt(String key, {int defaultValue = 0}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  static Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  static String getString(String key, {String defaultValue = ''}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  static Future<bool> setJson(String key, Map<String, dynamic> value) async {
    return await _preferences!.setString(key, jsonEncode(value));
  }

  static Map<String, dynamic>? getJson(String key) {
    final data = _preferences?.getString(key);

    if (data == null || data.isEmpty) {
      return null;
    }

    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  static Future<bool> clear() async {
    return await _preferences!.clear();
  }

  static bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}