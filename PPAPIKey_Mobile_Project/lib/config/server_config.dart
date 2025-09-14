// Server Configuration
// Thay đổi các URL này để kết nối đến server của bạn

class ServerConfig {
  // Main API Server
  static const String mainServerUrl = 'https://api.ppapikey.com';
  
  // CTV Server  
  static const String ctvServerUrl = 'https://ctv.ppapikey.com';
  
  // Development URLs (uncomment để sử dụng local server)
  // static const String mainServerUrl = 'http://localhost:3000';
  // static const String ctvServerUrl = 'http://localhost:3001';
  
  // Production URLs (uncomment để sử dụng production server)
  // static const String mainServerUrl = 'https://api.ppapikey.com';
  // static const String ctvServerUrl = 'https://ctv.ppapikey.com';
  
  // Test URLs (uncomment để sử dụng test server)
  // static const String mainServerUrl = 'https://test-api.ppapikey.com';
  // static const String ctvServerUrl = 'https://test-ctv.ppapikey.com';
  
  // API Endpoints
  static const Map<String, String> endpoints = {
    'login': '/auth/login',
    'register': '/auth/register',
    'logout': '/auth/logout',
    'profile': '/user/profile',
    'apiKeys': '/api/keys',
    'dashboard': '/dashboard',
    'ctvLogin': '/ctv/login',
    'ctvDashboard': '/ctv/dashboard',
    'ctvRecover': '/ctv/recover',
  };
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Timeout settings (milliseconds)
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Get full URL for main server endpoint
  static String getMainServerUrl(String endpoint) {
    return '$mainServerUrl/api/$apiVersion$endpoint';
  }
  
  // Get full URL for CTV server endpoint
  static String getCtvServerUrl(String endpoint) {
    return '$ctvServerUrl/api/$apiVersion$endpoint';
  }
  
  // Health check URLs
  static String get mainServerHealthUrl => '$mainServerUrl/health';
  static String get ctvServerHealthUrl => '$ctvServerUrl/health';
}
