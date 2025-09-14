import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  ThemeService(this.prefs) {
    _loadSettings();
  }

  final SharedPreferences prefs;
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('vi', 'VN');

  void _loadSettings() {
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    final localeCode = prefs.getString('locale') ?? 'vi';
    _locale = Locale(localeCode);
  }

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  ThemeData get lightTheme => ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    useMaterial3: true,
    fontFamily: 'Roboto',
  );

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }
}