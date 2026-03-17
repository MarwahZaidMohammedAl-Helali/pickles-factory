import 'dart:async';
import 'api_service.dart';

class KeepAliveService {
  static final KeepAliveService _instance = KeepAliveService._internal();
  final ApiService _apiService = ApiService();
  Timer? _timer;

  factory KeepAliveService() {
    return _instance;
  }

  KeepAliveService._internal();

  /// Start the keep-alive service - pings backend every 4 minutes
  void start() {
    if (_timer != null) return; // Already running

    _timer = Timer.periodic(const Duration(minutes: 4), (_) async {
      try {
        await _apiService.get('/users');
      } catch (e) {
        // Silently fail - this is just a keep-alive ping
      }
    });
  }

  /// Stop the keep-alive service
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if service is running
  bool get isRunning => _timer != null;
}
