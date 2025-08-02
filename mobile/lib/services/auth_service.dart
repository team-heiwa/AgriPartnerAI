import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../api/api_client.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  String? _authToken;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null;
  String? get authToken => _authToken;
  
  Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.login(email, password);
      
      _authToken = response['token'];
      _currentUser = User.fromJson(response['user']);
      
      await AppConfig.prefs.setString('auth_token', _authToken!);
      await AppConfig.prefs.setString('user_id', _currentUser!.id);
      
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<void> logout() async {
    _authToken = null;
    _currentUser = null;
    
    await AppConfig.prefs.remove('auth_token');
    await AppConfig.prefs.remove('user_id');
    
    notifyListeners();
  }
  
  Future<void> checkAuthStatus() async {
    final token = AppConfig.prefs.getString('auth_token');
    if (token != null) {
      _authToken = token;
      // TODO: Fetch user details from API
      notifyListeners();
    }
  }
}