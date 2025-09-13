import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService extends ChangeNotifier {
  final SharedPreferences prefs;
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userInfo;

  AuthService(this.prefs) {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userInfo => _userInfo;

  void _loadAuthState() {
    _token = prefs.getString('auth_token');
    final userInfoString = prefs.getString('user_info');
    if (userInfoString != null) {
      _userInfo = jsonDecode(userInfoString);
    }
    _isAuthenticated = _token != null && _token!.isNotEmpty;
    notifyListeners();
  }

  Future<bool> login(String emailOrUsername, String password, {bool rememberMe = false}) async {
    try {
      // Simulate API call - replace with actual API endpoint
      final response = await http.post(
        Uri.parse('https://api.ppapikey.dev/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userInfo = data['user'];
        _isAuthenticated = true;

        if (rememberMe) {
          await prefs.setString('auth_token', _token!);
          await prefs.setString('user_info', jsonEncode(_userInfo));
        }

        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ppapikey.dev/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'full_name': fullName,
          'password': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _userInfo = null;
    _isAuthenticated = false;
    
    await prefs.remove('auth_token');
    await prefs.remove('user_info');
    
    notifyListeners();
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ppapikey.dev/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }

  Future<bool> forgotPassword(String emailOrUsername) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.ppapikey.dev/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_username': emailOrUsername,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    }
  }
}
