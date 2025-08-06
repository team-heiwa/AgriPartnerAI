import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static late SharedPreferences _prefs;
  
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.agripartner.ai',
  );
  
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs => _prefs;
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
}