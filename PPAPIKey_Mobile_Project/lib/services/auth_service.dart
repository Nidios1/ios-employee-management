import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  AuthService(this.prefs) {
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _currentServer = prefs.getString('current_server');
  }

  final SharedPreferences prefs;
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _currentServer;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentServer => _currentServer;

  Future<bool> login(String username, String password, {String server = 'main'}) async {
    try {
      Map<String, dynamic> result;
      
      if (server == 'ctv') {
        result = await _apiService.ctvLogin(username, password);
      } else {
        result = await _apiService.login(username, password);
      }

      if (result['success'] == true) {
        _isAuthenticated = true;
        _currentServer = server;
        await prefs.setBool('is_authenticated', true);
        await prefs.setString('current_server', server);
        notifyListeners();
        return true;
      } else {
        // Show error message
        throw Exception(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      throw Exception('Connection error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    _isAuthenticated = false;
    _currentServer = null;
    await prefs.setBool('is_authenticated', false);
    await prefs.remove('current_server');
    notifyListeners();
  }

  Future<bool> checkServerStatus() async {
    return await _apiService.checkServerStatus();
  }
}