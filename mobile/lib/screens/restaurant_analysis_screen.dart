import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/restaurant.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';

class RestaurantAnalysisScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantAnalysisScreen({super.key, required this.restaurant});

  @override
  State<RestaurantAnalysisScreen> createState() => _RestaurantAnalysisScreenState();
}

class _RestaurantAnalysisScreenState extends State<RestaurantAnalysisScreen> {
  final TransactionService _transactionService = TransactionService();
  List<Transaction>? _allTransactions;
  List<Transaction>? _filteredTransactions;
  bool _isLoading = true;
  String? _errorMessage;
  
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.initialize();
      final transactions = await _transactionService.getTransactions(widget.restaurant.id);
      
      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyDateFilter() {
    if (_allTransactions == null) return;

    setState(() {
      _filteredTransactions = _allTransactions!.where((transaction) {
        if (_startDate != null && transaction.date.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && transaction.date.isAfter(_endDate!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      _applyDateFilter();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      _applyDateFilter();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filteredTransactions = _allTransactions;
    });
  }

  int _calculateBalance() {
    if (_filteredTransactions == null) return 0;
    
    int balance = 0;
    for (var transaction in _filteredTransactions!) {
      balance += transaction.jarsSold - transaction.jarsReturned;
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تحليلات ${widget.restaurant.name}'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadTransactions,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter Section
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تصفية حسب التاريخ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectStartDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _startDate == null
                              ? 'من تاريخ'
                              : DateFormat('yyyy-MM-dd').format(_startDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectEndDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          _endDate == null
                              ? 'إلى تاريخ'
                              : DateFormat('yyyy-MM-dd').format(_endDate!),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_startDate != null || _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('مسح التصفية'),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Summary Card
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'الملخص',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'عدد المعاملات',
                      '${_filteredTransactions?.length ?? 0}',
                      Icons.receipt,
                    ),
                    _buildSummaryItem(
                      'الرصيد',
                      '${_calculateBalance()}',
                      Icons.account_balance_wallet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Transactions List
        Expanded(
          child: _filteredTransactions == null || _filteredTransactions!.isEmpty
              ? const Center(child: Text('لا توجد معاملات'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredTransactions!.length,
                  itemBuilder: (context, index) {
                    final transaction = _filteredTransactions![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.receipt,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          DateFormat('yyyy-MM-dd').format(transaction.date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('علب مباعة: ${transaction.jarsSold}'),
                            Text('علب مرتجعة: ${transaction.jarsReturned}'),
                            Text(
                              'الرصيد: ${transaction.jarsSold - transaction.jarsReturned}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
