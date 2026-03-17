import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/restaurant.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/restaurant_service.dart';
import '../services/transaction_service.dart';
import '../services/product_service.dart';
import '../services/pdf_service.dart';
import '../utils/formatters.dart';
import '../widgets/transaction_list_widget.dart';
import 'add_transaction_screen.dart';
import 'restaurant_analysis_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();
  final PdfService _pdfService = PdfService();
  Restaurant? _restaurantDetails;
  List<Transaction>? _transactions;
  Map<String, Product>? _productMap;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
  }

  Future<void> _loadRestaurantDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _restaurantService.initialize();
      await _transactionService.initialize();
      await _productService.initialize();

      final details = await _restaurantService.getRestaurantDetails(widget.restaurant.id);
      final transactions = await _transactionService.getTransactions(widget.restaurant.id);
      final products = await _productService.getProducts();

      final productMap = <String, Product>{};
      for (var product in products) {
        productMap[product.id] = product;
      }

      setState(() {
        _restaurantDetails = details;
        _transactions = transactions;
        _productMap = productMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(restaurantId: widget.restaurant.id),
      ),
    );

    if (result == true) {
      _loadRestaurantDetails();
    }
  }

  Future<void> _generatePdfReport() async {
    if (_restaurantDetails == null || _transactions == null || _productMap == null) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdfFile = await _pdfService.generateRestaurantReport(
        restaurant: _restaurantDetails!,
        transactions: _transactions!,
        productMap: _productMap!,
      );

      setState(() {
        _isGeneratingPdf = false;
      });

      if (mounted) {
        // Show options dialog
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تقرير PDF'),
              content: const Text('تم إنشاء التقرير بنجاح. ماذا تريد أن تفعل؟'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pdfService.printReport(pdfFile);
                  },
                  child: const Text('طباعة'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pdfService.shareReport(pdfFile);
                  },
                  child: const Text('مشاركة'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingPdf = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في إنشاء التقرير: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.restaurant.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantAnalysisScreen(
                      restaurant: widget.restaurant,
                    ),
                  ),
                );
              },
              tooltip: 'التحليلات',
            ),
            IconButton(
              icon: _isGeneratingPdf
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              onPressed: _isGeneratingPdf ? null : _generatePdfReport,
              tooltip: 'تقرير PDF',
            ),
          ],
        ),
        body: _buildBody(l10n),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddTransaction,
          child: const Icon(Icons.add),
        ),
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
              onPressed: _loadRestaurantDetails,
              child: Text(l10n.retry ?? 'إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurantDetails,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Restaurant Header with Photo
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Restaurant Photo
                if (_restaurantDetails?.photoUrl != null && _restaurantDetails!.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      _restaurantDetails!.photoUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.restaurant,
                            size: 80,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 80,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                
                // Restaurant Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'عدد العلب الفارغة:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${(_restaurantDetails?.balance ?? 0.0).abs().toInt()}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            l10n.transactionsList,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_transactions != null)
            TransactionListWidget(
              transactions: _transactions!,
              productMap: _productMap,
              onTransactionUpdated: _loadRestaurantDetails,
            ),
        ],
      ),
    );
  }
}
