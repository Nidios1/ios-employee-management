import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  
  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  // Get authentication headers
  Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Login to main server
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getApiUrl(ApiConfig.loginEndpoint)),
        headers: _authHeaders,
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _authToken = data['token'];
          return {'success': true, 'data': data};
        }
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Login to CTV server
  Future<Map<String, dynamic>> ctvLogin(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getCtvUrl(ApiConfig.ctvLoginEndpoint)),
        headers: _authHeaders,
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _authToken = data['token'];
          return {'success': true, 'data': data};
        }
        return {'success': false, 'message': data['message'] ?? 'CTV Login failed'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getApiUrl(ApiConfig.dashboardEndpoint)),
        headers: _authHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Get API keys
  Future<Map<String, dynamic>> getApiKeys() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getApiUrl(ApiConfig.apiKeysEndpoint)),
        headers: _authHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getApiUrl(ApiConfig.logoutEndpoint)),
        headers: _authHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.connectTimeout));

      _authToken = null;
      
      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      _authToken = null;
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Check server status
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: 5000));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
