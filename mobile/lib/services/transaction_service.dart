import 'api_service.dart';
import '../models/transaction.dart';

class TransactionService {
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    await _apiService.loadToken();
  }

  Future<List<Transaction>> getTransactions(String restaurantId) async {
    final response = await _apiService.get('/transactions?restaurantId=$restaurantId');
    final data = response['data'] as List<dynamic>;
    return data.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<Transaction> addTransaction({
    required String restaurantId,
    required String productId,
    required DateTime date,
    required int jarsSold,
    required int jarsReturned,
  }) async {
    final response = await _apiService.post('/transactions', {
      'restaurantId': restaurantId,
      'productId': productId,
      'date': date.toIso8601String(),
      'jarsSold': jarsSold,
      'jarsReturned': jarsReturned,
    });
    final data = response['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  Future<Transaction> updateTransaction({
    required String transactionId,
    required int jarsReturned,
    required DateTime returnDate,
  }) async {
    final response = await _apiService.put('/transactions/$transactionId', {
      'jarsReturned': jarsReturned,
      'returnDate': returnDate.toIso8601String(),
      'isCompleted': true,
    });
    final data = response['data'] as Map<String, dynamic>;
    return Transaction.fromJson(data);
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _apiService.delete('/transactions/$transactionId');
  }
}
