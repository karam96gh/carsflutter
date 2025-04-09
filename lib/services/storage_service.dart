import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // مفاتيح التخزين
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _themeKey = 'app_theme';
  static const String _languageKey = 'app_language';

  // تخزين التوكن
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // الحصول على التوكن
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // حذف التوكن
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // تخزين بيانات المستخدم
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  // الحصول على بيانات المستخدم
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString == null) {
      return null;
    }

    return json.decode(userDataString) as Map<String, dynamic>;
  }

  // حذف بيانات المستخدم
  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  // تخزين سمة التطبيق
  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  // الحصول على سمة التطبيق
  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  // تخزين لغة التطبيق
  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  // الحصول على لغة التطبيق
  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  // حذف جميع البيانات
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // تخزين بيانات مخصصة
  Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      await prefs.setString(key, json.encode(value));
    }
  }

  // الحصول على بيانات مخصصة
  Future<dynamic> getData(String key, {String type = 'string'}) async {
    final prefs = await SharedPreferences.getInstance();

    switch (type) {
      case 'string':
        return prefs.getString(key);
      case 'int':
        return prefs.getInt(key);
      case 'double':
        return prefs.getDouble(key);
      case 'bool':
        return prefs.getBool(key);
      case 'stringList':
        return prefs.getStringList(key);
      case 'json':
        final jsonString = prefs.getString(key);
        if (jsonString == null) return null;
        return json.decode(jsonString);
      default:
        return prefs.getString(key);
    }
  }

  // حذف بيانات مخصصة
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}