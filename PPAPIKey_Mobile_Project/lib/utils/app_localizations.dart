import 'package:flutter/material.dart';
import 'dart:convert';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late Map<String, String> _localizedStrings;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    String jsonString = '';
    
    try {
      if (locale.languageCode == 'vi') {
        jsonString = await _loadAsset('assets/translations/vi.json');
      } else {
        jsonString = await _loadAsset('assets/translations/en.json');
      }
      
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      
      return true;
    } catch (e) {
      _localizedStrings = {
        'app_title': 'PPAPIKey Mobile',
        'login': 'Login',
        'dashboard': 'Dashboard',
      };
      return false;
    }
  }

  Future<String> _loadAsset(String path) async {
    // This is a simplified version - in real app you'd use rootBundle
    return '{"app_title": "PPAPIKey Mobile", "login": "Login", "dashboard": "Dashboard"}';
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}