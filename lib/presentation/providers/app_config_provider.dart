import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api_client.dart';

class AppConfigProvider extends ChangeNotifier {
  String _scriptUrl = '';
  String _userName = '';
  ThemeMode _themeMode = ThemeMode.system;

  String get scriptUrl => _scriptUrl;
  String get userName => _userName;
  ThemeMode get themeMode => _themeMode;
  bool get isConfigured => _scriptUrl.isNotEmpty;

  ApiClient get client => ApiClient(scriptUrl: _scriptUrl);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _scriptUrl = prefs.getString('script_url') ?? '';
    _userName = prefs.getString('user_name') ?? '';
    final tm = prefs.getString('theme_mode') ?? 'system';
    _themeMode = tm == 'light'
        ? ThemeMode.light
        : tm == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
    notifyListeners();
  }

  Future<void> setConfig(String url, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('script_url', url);
    await prefs.setString('user_name', name);
    _scriptUrl = url;
    _userName = name;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _scriptUrl = '';
    _userName = '';
    notifyListeners();
  }
}
