import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
    // Warm up the backend to avoid cold start delays
    _warmupBackend();
  }

  Future<void> _warmupBackend() async {
    try {
      // Make a simple request to wake up the backend
      await _apiService.get('/health').timeout(
        const Duration(seconds: 5),
        onTimeout: () => {'success': false},
      );
    } catch (e) {
      // Silently fail - this is just a warmup
    }
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
