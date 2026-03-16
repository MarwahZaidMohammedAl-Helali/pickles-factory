import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
  }

  Future<User> login(String username, String password) async {
    final response = await _apiService.post('/auth/login', {
      'username': username,
      'password': password,
    });

    final data = response['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final userData = data['user'] as Map<String, dynamic>;

    await _apiService.setToken(token);

    return User.fromJson(userData);
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  bool isAuthenticated() {
    return _apiService.token != null;
  }

  String? get token => _apiService.token;
}
