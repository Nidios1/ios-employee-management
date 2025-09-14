class ApiConfig {
  // Base URLs for different servers
  static const String baseUrl = 'https://api.ppapikey.com';
  static const String ctvBaseUrl = 'https://ctv.ppapikey.com';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/user/profile';
  static const String apiKeysEndpoint = '/api/keys';
  static const String dashboardEndpoint = '/dashboard';
  
  // CTV Server Endpoints
  static const String ctvLoginEndpoint = '/ctv/login';
  static const String ctvDashboardEndpoint = '/ctv/dashboard';
  static const String ctvRecoverEndpoint = '/ctv/recover';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeout settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Get full URL for API endpoint
  static String getApiUrl(String endpoint) {
    return '$baseUrl/api/$apiVersion$endpoint';
  }
  
  // Get full URL for CTV endpoint
  static String getCtvUrl(String endpoint) {
    return '$ctvBaseUrl/api/$apiVersion$endpoint';
  }
}
