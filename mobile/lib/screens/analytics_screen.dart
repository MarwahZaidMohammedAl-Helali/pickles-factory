import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../models/restaurant.dart';
import '../services/transaction_service.dart';
import '../services/product_service.dart';
import '../services/restaurant_service.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();
  final RestaurantService _restaurantService = RestaurantService();

  List<Transaction>? _allTransactions;
  List<Product>? _products;
  List<Restaurant>? _restaurants;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.initialize();
      await _productService.initialize();
      await _restaurantService.initialize();

      final products = await _productService.getProducts();
      final restaurants = await _restaurantService.getRestaurants();

      // Get all transactions from all restaurants
      List<Transaction> allTransactions = [];
      for (var restaurant in restaurants) {
        final transactions = await _transactionService.getTransactions(restaurant.id);
        allTransactions.addAll(transactions);
      }

      setState(() {
        _allTransactions = allTransactions;
        _products = products;
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Calculate total jars sold
  int _getTotalJarsSold() {
    if (_allTransactions == null) return 0;
    return _allTransactions!.fold(0, (sum, t) => sum + t.jarsSold);
  }

  // Calculate total jars returned
  int _getTotalJarsReturned() {
    if (_allTransactions == null) return 0;
    return _allTransactions!.fold(0, (sum, t) => sum + t.jarsReturned);
  }

  // Calculate net jars (sold - returned)
  int _getNetJars() {
    return _getTotalJarsSold() - _getTotalJarsReturned();
  }

  // Calculate return rate percentage
  double _getReturnRate() {
    final sold = _getTotalJarsSold();
    if (sold == 0) return 0;
    return (_getTotalJarsReturned() / sold) * 100;
  }

  // Calculate total revenue
  double _getTotalRevenue() {
    if (_allTransactions == null || _products == null) return 0;

    double total = 0;
    for (var transaction in _allTransactions!) {
      final product = _products!.firstWhere(
        (p) => p.id == transaction.productId,
        orElse: () => Product(id: '', name: '', price: 0),
      );
      final used = transaction.jarsSold - transaction.jarsReturned;
      total += used * product.price;
    }
    return total;
  }

  // Get returns by restaurant
  Map<String, int> _getReturnsByRestaurant() {
    if (_allTransactions == null || _restaurants == null) return {};

    Map<String, int> returns = {};
    for (var transaction in _allTransactions!) {
      final restaurant = _restaurants!.firstWhere(
        (r) => r.id == transaction.restaurantId,
        orElse: () => Restaurant(id: '', name: 'غير معروف'),
      );
      returns[restaurant.name] = (returns[restaurant.name] ?? 0) + transaction.jarsReturned;
    }
    return returns;
  }

  // Get returns by product
  Map<String, int> _getReturnsByProduct() {
    if (_allTransactions == null || _products == null) return {};

    Map<String, int> returns = {};
    for (var transaction in _allTransactions!) {
      final product = _products!.firstWhere(
        (p) => p.id == transaction.productId,
        orElse: () => Product(id: '', name: 'غير معروف', price: 0),
      );
      returns[product.name] = (returns[product.name] ?? 0) + transaction.jarsReturned;
    }
    return returns;
  }

  // Get top 3 restaurants by return rate
  List<MapEntry<String, double>> _getTopRestaurantsByReturnRate() {
    if (_allTransactions == null || _restaurants == null) return [];

    Map<String, int> soldByRestaurant = {};
    Map<String, int> returnsByRestaurant = {};

    for (var transaction in _allTransactions!) {
      final restaurant = _restaurants!.firstWhere(
        (r) => r.id == transaction.restaurantId,
        orElse: () => Restaurant(id: '', name: 'غير معروف'),
      );
      soldByRestaurant[restaurant.name] = (soldByRestaurant[restaurant.name] ?? 0) + transaction.jarsSold;
      returnsByRestaurant[restaurant.name] = (returnsByRestaurant[restaurant.name] ?? 0) + transaction.jarsReturned;
    }

    List<MapEntry<String, double>> returnRates = [];
    for (var entry in soldByRestaurant.entries) {
      final sold = entry.value;
      final returned = returnsByRestaurant[entry.key] ?? 0;
      if (sold > 0) {
        final rate = (returned / sold) * 100;
        returnRates.add(MapEntry(entry.key, rate));
      }
    }

    returnRates.sort((a, b) => b.value.compareTo(a.value));
    return returnRates.take(3).toList();
  }

  // Get average return rate per restaurant
  double _getAverageReturnRate() {
    if (_restaurants == null || _restaurants!.isEmpty) return 0;

    final topRates = _getTopRestaurantsByReturnRate();
    if (topRates.isEmpty) return 0;

    final sum = topRates.fold(0.0, (sum, entry) => sum + entry.value);
    return sum / topRates.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التحليلات والإحصائيات'),
        ),
        body: _buildBody(l10n),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text(l10n.retry ?? 'إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    final totalSold = _getTotalJarsSold();
    final totalReturned = _getTotalJarsReturned();
    final netJars = _getNetJars();
    final returnRate = _getReturnRate();
    final totalRevenue = _getTotalRevenue();
    final returnsByRestaurant = _getReturnsByRestaurant();
    final returnsByProduct = _getReturnsByProduct();
    final topRestaurantsByReturnRate = _getTopRestaurantsByReturnRate();
    final avgReturnRate = _getAverageReturnRate();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Overview Metrics
            Text(
              'نظرة عامة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'إجمالي الإيرادات',
                    Formatters.formatCurrency(totalRevenue, l10n.currency),
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'عدد المطاعم',
                    '${_restaurants?.length ?? 0}',
                    Icons.restaurant,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 2: Jars Metrics
            Text(
              'إحصائيات البرطمانات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'البرطمانات المباعة',
                    '$totalSold برطمان',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'صافي البرطمانات',
                    '$netJars برطمان',
                    Icons.inventory_2,
                    Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section 3: Returns Metrics (Focus Area)
            Text(
              'إحصائيات المرتجعات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'إجمالي المرتجعات',
                    '$totalReturned برطمان',
                    Icons.keyboard_return,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'نسبة المرتجعات',
                    '${returnRate.toStringAsFixed(1)}%',
                    Icons.percent,
                    Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'متوسط نسبة المرتجعات للمطاعم',
              '${avgReturnRate.toStringAsFixed(1)}%',
              Icons.analytics,
              Colors.purple,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // Section 4: Returns by Restaurant Chart
            Text(
              'المرتجعات حسب المطعم',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (returnsByRestaurant.isNotEmpty)
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: returnsByRestaurant.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final restaurantName = returnsByRestaurant.keys.elementAt(group.x.toInt());
                          return BarTooltipItem(
                            '$restaurantName\n${rod.toY.toInt()} برطمان',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < returnsByRestaurant.keys.length) {
                              final name = returnsByRestaurant.keys.elementAt(index);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: returnsByRestaurant.entries.map((entry) {
                      final index = returnsByRestaurant.keys.toList().indexOf(entry.key);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.toDouble(),
                            color: Colors.red,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Section 5: Returns by Product Chart
            Text(
              'المرتجعات حسب المنتج',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (returnsByProduct.isNotEmpty)
              Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: PieChart(
                  PieChartData(
                    sections: returnsByProduct.entries.map((entry) {
                      final total = returnsByProduct.values.reduce((a, b) => a + b);
                      final percentage = (entry.value / total) * 100;
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '${percentage.toStringAsFixed(1)}%',
                        color: _getColorForIndex(returnsByProduct.keys.toList().indexOf(entry.key)),
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Legend for Returns by Product
            if (returnsByProduct.isNotEmpty)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: returnsByProduct.entries.map((entry) {
                  final index = returnsByProduct.keys.toList().indexOf(entry.key);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.key}: ${entry.value} برطمان',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Section 6: Top Restaurants by Return Rate
            Text(
              'أعلى المطاعم في نسبة المرتجعات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (topRestaurantsByReturnRate.isNotEmpty)
              ...topRestaurantsByReturnRate.asMap().entries.map((entry) {
                final index = entry.key;
                final restaurant = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: index == 0 ? Colors.red : Colors.grey.shade300,
                      width: index == 0 ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index == 0 ? Colors.red : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'نسبة المرتجعات: ${restaurant.value.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.warning,
                        color: index == 0 ? Colors.red : Colors.orange,
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
