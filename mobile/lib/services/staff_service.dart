import 'api_service.dart';
import '../models/user.dart';

class StaffService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
  }

  Future<List<User>> getStaff() async {
    final response = await _apiService.get('/users');
    final data = response['data'] as List<dynamic>;
    return data.map((json) => User.fromJson(json)).toList();
  }

  Future<User> addStaff(String username, String password) async {
    final response = await _apiService.post('/users', {
      'username': username,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<User> updateStaff(String userId, {String? username, String? password}) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (password != null) body['password'] = password;

    final response = await _apiService.put('/users/$userId', body);
    final data = response['data'] as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> deleteStaff(String userId) async {
    await _apiService.delete('/users/$userId');
  }
}
