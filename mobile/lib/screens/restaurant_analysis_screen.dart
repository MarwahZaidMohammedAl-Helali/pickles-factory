import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../providers/auth_provider.dart';
import '../screens/add_transaction_screen.dart';

class RestaurantAnalysisScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantAnalysisScreen({super.key, required this.restaurant});

  @override
  State<RestaurantAnalysisScreen> createState() => _RestaurantAnalysisScreenState();
}

class _RestaurantAnalysisScreenState extends State<RestaurantAnalysisScreen> {
  final TransactionService _transactionService = TransactionService();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedNotes = <String>{};
  
  List<Transaction>? _allTransactions;
  bool _isLoading = true;
  String? _errorMessage;
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showOnlyPending = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Transaction> get _filteredTransactions {
    if (_allTransactions == null) return [];
    
    var filtered = _allTransactions!;

    // Filter by date range
    if (_startDate != null) {
      filtered = filtered.where((t) => t.deliveryDate.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((t) => t.deliveryDate.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }

    // Filter by pending returns
    if (_showOnlyPending) {
      filtered = filtered.where((t) => t.jarsEmpty == 0).toList();
    }

    // Filter by search query (notes)
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => 
        t.notes != null && t.notes!.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  int _calculateBalance() {
    final filtered = _filteredTransactions;
    
    int balance = 0;
    for (var transaction in filtered) {
      balance += transaction.jarsEmpty; // Sum of returned jars only
    }
    return balance;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('تحليلات ${widget.restaurant.name}'),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
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
              style: TextStyle(color: theme.colorScheme.error),
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

    final filteredTransactions = _filteredTransactions;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Filter Section
        _buildFilterSection(theme),
        const SizedBox(height: 16),

        // Summary Card
        Card(
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
                      '${filteredTransactions.length}',
                      Icons.receipt,
                      theme,
                    ),
                    _buildSummaryItem(
                      'الرصيد',
                      '${_calculateBalance()}',
                      Icons.account_balance_wallet,
                      theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Transactions count
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'عدد المعاملات: ${filteredTransactions.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),

        // Table header
        _buildTableHeader(theme),

        // Table rows
        if (filteredTransactions.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'لا توجد معاملات تطابق الفلتر',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...filteredTransactions.map((transaction) => 
            _buildTableRow(context, transaction, theme, isAdmin)
          ),
      ],
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'فلترة المعاملات',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Search by notes
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث في الملاحظات...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Date range and pending filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Start date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _startDate != null ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'من تاريخ',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (_startDate != null) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _startDate = null;
                            });
                          },
                          child: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // End date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _endDate != null ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 4),
                      Text(
                        _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'إلى تاريخ',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (_endDate != null) ...[
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                          child: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Pending filter
              InkWell(
                onTap: () {
                  setState(() {
                    _showOnlyPending = !_showOnlyPending;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _showOnlyPending ? theme.colorScheme.primaryContainer : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showOnlyPending ? Icons.check_box : Icons.check_box_outline_blank,
                        size: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'بانتظار الإرجاع',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              'التاريخ',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'المسلم',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'المرتجع',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'ملاحظات',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 64), // Space for edit and delete buttons
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Transaction transaction,
    ThemeData theme,
    bool isAdmin,
  ) {
    final isExpanded = _expandedNotes.contains(transaction.id);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(transaction.deliveryDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  if (transaction.createdByUsername != null)
                    Text(
                      transaction.createdByUsername!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
            
            // Delivered
            SizedBox(
              width: 50,
              child: Text(
                '${transaction.jarsDelivered}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            
            // Returned
            SizedBox(
              width: 50,
              child: Text(
                '${transaction.jarsEmpty}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            
            // Notes
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (transaction.notes != null && transaction.notes!.isNotEmpty) {
                      setState(() {
                        if (isExpanded) {
                          _expandedNotes.remove(transaction.id);
                        } else {
                          _expandedNotes.add(transaction.id);
                        }
                      });
                    }
                  },
                  child: Text(
                    transaction.notes ?? '-',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 11,
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            
            // Edit and Delete buttons
            if (isAdmin)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    iconSize: 18,
                    onPressed: () => _editTransaction(context, transaction),
                    icon: Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    iconSize: 18,
                    onPressed: () => _deleteTransaction(context, transaction),
                    icon: Icon(
                      Icons.delete,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(width: 64),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, size: 32, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          existingTransaction: transaction,
        ),
      ),
    );

    if (result == true) {
      _loadTransactions();
    }
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transactionService.initialize();
        await _transactionService.deleteTransaction(transaction.id);

        _loadTransactions();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المعاملة بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الحذف: $e')),
          );
        }
      }
    }
  }
}
