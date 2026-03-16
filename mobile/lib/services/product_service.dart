import 'api_service.dart';
import '../models/product.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
  }

  Future<List<Product>> getProducts() async {
    final response = await _apiService.get('/products');
    final data = response['data'] as List<dynamic>;
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> addProduct(String name, double price) async {
    final response = await _apiService.post('/products', {
      'name': name,
      'price': price,
    });
    final data = response['data'] as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  Future<Product> updateProduct(String id, String name, double price) async {
    final response = await _apiService.put('/products/$id', {
      'name': name,
      'price': price,
    });
    final data = response['data'] as Map<String, dynamic>;
    return Product.fromJson(data);
  }

  Future<void> deleteProduct(String id) async {
    await _apiService.delete('/products/$id');
  }
}
