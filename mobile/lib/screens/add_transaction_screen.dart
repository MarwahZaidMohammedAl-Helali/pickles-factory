import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/restaurant.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/restaurant_service.dart';
import '../services/product_service.dart';
import '../services/transaction_service.dart';
import '../utils/formatters.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? restaurantId;
  final Transaction? existingTransaction; // For adding returns to existing transaction

  const AddTransactionScreen({
    super.key,
    this.restaurantId,
    this.existingTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jarsDeliveredController = TextEditingController();
  final _jarsReturnedController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();

  List<Restaurant>? _restaurants;
  List<Product>? _products;
  String? _selectedRestaurantId;
  String? _selectedProductId;
  DateTime _deliveryDate = DateTime.now();
  DateTime? _returnDate;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isAddingReturn = false; // Are we adding returns to existing transaction?
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedRestaurantId = widget.restaurantId;
    
    // If editing existing transaction (adding returns)
    if (widget.existingTransaction != null) {
      _isAddingReturn = true;
      _selectedRestaurantId = widget.existingTransaction!.restaurantId;
      _selectedProductId = widget.existingTransaction!.productId;
      _deliveryDate = widget.existingTransaction!.deliveryDate;
      _jarsDeliveredController.text = widget.existingTransaction!.jarsDelivered.toString();
      _returnDate = DateTime.now();
    }
    
    _loadData();
  }

  @override
  void dispose() {
    _jarsDeliveredController.dispose();
    _jarsReturnedController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      await _restaurantService.initialize();
      await _productService.initialize();

      final restaurants = await _restaurantService.getRestaurants();
      final products = await _productService.getProducts();
      
      // Auto-select first product if available (since we only have one product)
      if (products.isNotEmpty && _selectedProductId == null) {
        _selectedProductId = products.first.id;
      }

      setState(() {
        _restaurants = restaurants;
        _products = products;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectDeliveryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (picked != null && picked != _deliveryDate) {
      setState(() {
        _deliveryDate = picked;
      });
    }
  }

  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? DateTime.now(),
      firstDate: _deliveryDate, // Can't return before delivery
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );

    if (picked != null) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // If restaurant is pre-selected from widget, use it
    final restaurantId = _selectedRestaurantId ?? widget.restaurantId;
    
    if (restaurantId == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار المطعم';
      });
      return;
    }
    
    if (_selectedProductId == null) {
      setState(() {
        _errorMessage = 'خطأ: لم يتم تحديد المنتج';
      });
      return;
    }

    // Prevent duplicate saves
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.initialize();
      
      if (_isAddingReturn) {
        // Update existing transaction with returns
        await _transactionService.updateTransaction(
          transactionId: widget.existingTransaction!.id,
          jarsReturned: int.parse(_jarsReturnedController.text),
        );
      } else {
        // Create new delivery transaction
        await _transactionService.addTransaction(
          restaurantId: restaurantId,
          productId: _selectedProductId!,
          date: _deliveryDate,
          jarsSold: int.parse(_jarsDeliveredController.text),
          jarsReturned: int.parse(_jarsReturnedController.text.isEmpty ? '0' : _jarsReturnedController.text),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isAddingReturn ? l10n.addReturn : l10n.addTransaction),
        ),
        body: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info card explaining the process
                      if (!_isAddingReturn)
                        Card(
                          color: theme.colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'سجل تاريخ التسليم والكمية المسلمة. يمكنك إضافة المرتجعات لاحقاً.',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Restaurant selector (only show if not pre-selected)
                      if (widget.restaurantId == null)
                        DropdownButtonFormField<String>(
                          value: _selectedRestaurantId,
                          decoration: InputDecoration(
                            labelText: l10n.selectRestaurant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            prefixIcon: const Icon(Icons.restaurant),
                          ),
                          items: _restaurants?.map((restaurant) {
                            return DropdownMenuItem(
                              value: restaurant.id,
                              child: Text(restaurant.name),
                            );
                          }).toList(),
                          onChanged: (_isLoading || _isAddingReturn)
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedRestaurantId = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return l10n.requiredField;
                            }
                            return null;
                          },
                        ),
                      if (widget.restaurantId == null) const SizedBox(height: 16),
                      
                      // Delivery date
                      InkWell(
                        onTap: (_isLoading || _isAddingReturn) ? null : () => _selectDeliveryDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.deliveryDate,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Formatters.formatDateArabic(_deliveryDate)),
                              if (!_isAddingReturn) const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Jars delivered
                      TextFormField(
                        controller: _jarsDeliveredController,
                        decoration: InputDecoration(
                          labelText: l10n.jarsDelivered,
                          hintText: 'عدد البرطمانات المسلمة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          prefixIcon: const Icon(Icons.local_shipping),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.requiredField;
                          }
                          final intValue = int.tryParse(value);
                          if (intValue == null || intValue < 0) {
                            return 'يجب أن يكون رقم صحيح';
                          }
                          return null;
                        },
                        enabled: !_isLoading && !_isAddingReturn,
                        readOnly: _isAddingReturn,
                      ),
                      const SizedBox(height: 16),
                      
                      // Jars returned (for new transactions)
                      if (!_isAddingReturn)
                        TextFormField(
                          controller: _jarsReturnedController,
                          decoration: InputDecoration(
                            labelText: 'العلب المرتجعة',
                            hintText: 'عدد البرطمانات المرتجعة (اختياري)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            prefixIcon: const Icon(Icons.assignment_return),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final intValue = int.tryParse(value);
                              if (intValue == null || intValue < 0) {
                                return 'يجب أن يكون رقم صحيح';
                              }
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                      
                      // Return section (only if adding returns)
                      if (_isAddingReturn) ...[
                        const SizedBox(height: 24),
                        Divider(thickness: 2, color: theme.colorScheme.primary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        
                        Text(
                          'إضافة المرتجعات',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Return date
                        InkWell(
                          onTap: _isLoading ? null : () => _selectReturnDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.returnDate,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              prefixIcon: const Icon(Icons.calendar_today),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _returnDate != null
                                      ? Formatters.formatDateArabic(_returnDate!)
                                      : 'اختر تاريخ الإرجاع',
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Jars returned
                        TextFormField(
                          controller: _jarsReturnedController,
                          decoration: InputDecoration(
                            labelText: l10n.jarsReturned,
                            hintText: 'عدد البرطمانات المرتجعة',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            prefixIcon: const Icon(Icons.assignment_return),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.requiredField;
                            }
                            final intValue = int.tryParse(value);
                            if (intValue == null || intValue < 0) {
                              return 'يجب أن يكون رقم صحيح';
                            }
                            final delivered = int.tryParse(_jarsDeliveredController.text) ?? 0;
                            if (intValue > delivered) {
                              return 'لا يمكن أن يكون المرتجع أكثر من المسلم';
                            }
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        
                        // Calculation display
                        if (_jarsDeliveredController.text.isNotEmpty && 
                            _jarsReturnedController.text.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('المسلم:', style: theme.textTheme.titleMedium),
                                    Text(
                                      _jarsDeliveredController.text,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('المرتجع:', style: theme.textTheme.titleMedium),
                                    Text(
                                      _jarsReturnedController.text,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(height: 24, thickness: 1),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'الفاضية:',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      (int.parse(_jarsDeliveredController.text) - 
                                       int.parse(_jarsReturnedController.text)).toString(),
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Error message
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: theme.colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // Save button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _isAddingReturn ? 'حفظ المرتجعات' : l10n.saveDelivery,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
