import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Using Render backend
  static const String baseUrl = 'https://pickles-factory-backend-joqj.onrender.com/api';
  String? _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  String? get token => _token;

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException('Request timeout - server may be starting up'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw ApiException('Request timeout - server may be starting up. Please try again.'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException('Request timeout - server may be starting up'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException('Request timeout - server may be starting up'),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(
        error['error']?['message'] ?? 'Request failed',
        statusCode: response.statusCode,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
