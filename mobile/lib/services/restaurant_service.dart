import 'api_service.dart';
import '../models/restaurant.dart';

class RestaurantService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
  }

  Future<List<Restaurant>> getRestaurants() async {
    final response = await _apiService.get('/restaurants');
    final data = response['data'] as List<dynamic>;
    return data.map((json) => Restaurant.fromJson(json)).toList();
  }

  Future<Restaurant> addRestaurant(String name) async {
    final response = await _apiService.post('/restaurants', {
      'name': name,
    });
    final data = response['data'] as Map<String, dynamic>;
    return Restaurant.fromJson(data);
  }

  Future<Restaurant> getRestaurantDetails(String id) async {
    final response = await _apiService.get('/restaurants/$id');
    final data = response['data'] as Map<String, dynamic>;
    return Restaurant.fromJson(data);
  }

  Future<Restaurant> updateRestaurant(String id, {String? name, String? photoUrl}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (photoUrl != null) body['photoUrl'] = photoUrl;

    final response = await _apiService.put('/restaurants/$id', body);
    final data = response['data'] as Map<String, dynamic>;
    return Restaurant.fromJson(data);
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    await _apiService.delete('/restaurants/$restaurantId');
  }
}
