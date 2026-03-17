import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/keep_alive_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final KeepAliveService _keepAliveService = KeepAliveService();
  User? _currentUser;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    await _authService.initialize();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _currentUser = await _authService.login(username, password);
    // Start keep-alive service after successful login
    _keepAliveService.start();
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    // Stop keep-alive service on logout
    _keepAliveService.stop();
    notifyListeners();
  }

  bool isAdmin() {
    return _currentUser?.role == 'admin';
  }

  bool isStaff() {
    return _currentUser?.role == 'staff';
  }
}
