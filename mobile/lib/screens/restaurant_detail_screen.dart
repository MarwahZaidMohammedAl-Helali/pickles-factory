import 'package:flutter/material.dart';
import 'dart:convert';
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

      final details = await _restaurantService.getRestaurantDetails(widget.restaurant.id);
      final transactions = await _transactionService.getTransactions(widget.restaurant.id);

      // Create empty product map - we don't need products anymore
      final productMap = <String, Product>{};

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

  // Helper method to build photo widget - handles both base64 and network URLs
  Widget _buildPhotoWidget(String photoUrl) {
    try {
      if (photoUrl.startsWith('data:image')) {
        // Base64 encoded image
        final base64String = photoUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      } else {
        // Network URL
        return Image.network(
          photoUrl,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        );
      }
    } catch (e) {
      return _buildErrorPlaceholder();
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 200,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.restaurant,
        size: 80,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Restaurant Photo
                if (_restaurantDetails?.photoUrl != null && _restaurantDetails!.photoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: _buildPhotoWidget(_restaurantDetails!.photoUrl!),
                  )
                else
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 100,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                
                // Restaurant Info
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurant.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'عدد العلب الفارغة',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(_restaurantDetails?.balance ?? 0.0).abs().toInt()}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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

          const SizedBox(height: 28),
          
          // Transactions Section
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
